require 'rspec'
require 'delegate'

class FloatWithError < SimpleDelegator
  EPSILON = 1e-9

  def ==(other)
    return false unless Numeric === other
    return true if super
    (self - other).abs < EPSILON
  end
end

module ValidatableStruct
  def self.new(*properties)
    Struct.new(*properties) do
      protected *properties

      def initialize(*properties)
        super
        validate!
      end

      def validate!
      end
    end
  end
end

class Volume < ValidatableStruct.new(:volume)
  private_class_method :new

  BASE_VOLUME = 1

  def self.def_unit(name, visible: true, &blk)
    volume = new(0).instance_eval(&blk)
    const_set(name, new(volume))
    @units ||= []
    @units.push(name.to_s) if visible
  end

  def_unit(:Base, visible: false) { BASE_VOLUME }
  def_unit(:Teaspoon) { 1 * Base.volume }
  def_unit(:Tablespoon) { 3 * Teaspoon.volume }
  def_unit(:Ounce) { 2 * Tablespoon.volume }
  def_unit(:Cup) { 8 * Ounce.volume }
  def_unit(:Pint) { 2 * Cup.volume }
  def_unit(:Quart) { 2 * Pint.volume }
  def_unit(:Gallon) { 4 * Quart.volume }
  def_unit(:Barrel) { 10 * Gallon.volume }

  def conversion_rate_for(other)
    1.0 * self.volume / other.volume
  end

  def self.install_core_extensions
    units = @units
    Numeric.class_eval do
      units.each do |unit_name|
        downcased = unit_name.downcase

        [downcased, "#{downcased}s"].each do |name|
          define_method name.to_sym do
            Amount.new(self, Volume.const_get(unit_name))
          end
        end
      end
    end
  end

end

class Amount < ValidatableStruct.new(:quantity, :unit)
  include Comparable

  def ==(other)
    return false unless self.class === other
    FloatWithError.new(converted_quantity(other.unit)) == other.quantity
  end

  def <=>(other)
    converted_quantity(other.unit) <=> other.quantity
  end

  def hash
    converted_quantity(Volume::Base).hash
  end

  def -@
    self.class.new(-quantity, unit)
  end

  [:+, :-, :/, :*].each do |op|
    define_method(op) do |other|
      simple_op(op, other)
    end
  end

  private

  def validate!
    raise ArgumentError.new(%{Quantity can't be NaN}) if quantity.to_f.nan?
  end

  def converted_quantity(other_unit)
    quantity * unit.conversion_rate_for(other_unit)
  end

  def simple_op(op, other)
    self.class.new(
      converted_quantity(other.unit).public_send(op, other.quantity),
      other.unit
    )
  end
end

Volume.install_core_extensions

RSpec.describe "Amount & Volume" do
  it "is good with ==" do
    expect(2.pints).to eq(2.pints)
    expect(2.pints).not_to eq(1.pint)

    expect(3.pints).not_to eq(2.pints)
    expect(2.quarts).not_to eq(Object)
    expect(2.tablespoons).not_to eq(nil)
    expect(3.pints).to eq(96.tablespoons)

    expect { nil.pints }.to raise_error(NoMethodError)
  end

  it "plays good with INFINITY" do
    expect(Float::INFINITY.pints).to eq(Float::INFINITY.cups)
    expect(-Float::INFINITY.ounces).not_to eq(Float::INFINITY.cups)
    expect(-Float::INFINITY.pints).to eq(-Float::INFINITY.ounces)
  end

  it "is comparable" do
    expect(2.pints).to be > 50.tablespoons
    expect(2.pints).to be < 1050.tablespoons
  end

  it "has good hash implementation" do
    expect(2.pints.hash).to eq(2.pints.hash)
    expect(2.pints.hash).to eq(4.cups.hash)
  end

  it "volumes cant be created out of Volume class" do
    expect { Volume.new(5) }.to raise_error
  end

  it "simple operations" do
    expect(4.pints + 5.pints).to eq(9.pints)
    expect(4.pints - 5.pints).to eq(-1.pints)
    expect(4.pints * 55.cups).to eq(27.5.gallons)
    expect(4.pints / 17.cups).to eq(0.470588235.cups)
  end

  it "comparing with floating error" do
    expect(0.4.pints * 53.pints).to eq(42.4.cups)
  end

  it "divide by 0 and working with NaN" do
    expect(2.barrels / 0.cups).to eq(Float::INFINITY.gallons)

    expect { Float::NAN.pints }.to raise_error
  end
end
