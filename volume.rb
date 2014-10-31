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

      def self.call(*properties)
        new(*properties)
      end
    end
  end
end

class Volume < ValidatableStruct.new(:volume)
  private_class_method :new

  BASE_VOLUME = 1

  Base = new(BASE_VOLUME)
  Teaspoon = new(1)
  Tablespoon = new(3)
  Ounce = new(6)
  Cup = new(48)
  Pint = new(96)
  Quart = new(192)
  Gallon = new(768)

  UNITS = %w(Teaspoon Tablespoon Ounce Cup Pint Quart Gallon)

  def conversion_rate_for(other)
    1.0 * self.volume / other.volume
  end

  def self.install_core_extensions
    Numeric.class_eval do
      UNITS.each do |unit_name|
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
    self.class.new(converted_quantity(other.unit).public_send(op, other.quantity), other.unit)
  end
end

Volume.install_core_extensions

RSpec.describe "Amount & Volume" do
  it "is good with ==" do
    expect(2.pints).to eq(2.pints)
    expect(2.pints).not_to eq(1.pint)

    expect(3.pints).not_to eq(2.pints)
    expect(2.pints).not_to eq(Object)
    expect(2.pints).not_to eq(nil)
    expect(3.pints).to eq(96.tablespoons)
  end

  it "plays good with INFINITY" do
    expect(Float::INFINITY.pints).to eq(Float::INFINITY.cups)
    expect(-Float::INFINITY.pints).not_to eq(Float::INFINITY.cups)
    expect(-Float::INFINITY.pints).to eq(-Float::INFINITY.cups)
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
    expect(2.pints / 0.cups).to eq(Float::INFINITY.gallons)

    expect { Float::NAN.pints }.to raise_error
  end
end
