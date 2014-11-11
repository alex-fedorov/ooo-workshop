class Interval < Struct.new(:value, :unit)
  EPS = 1e-9

  protected :value, :unit

  include Comparable

  def <=>(other)
    raise ArgumentError unless self.compatible?(other)

    self.convert_to_base <=> other.convert_to_base
  end

  def ==(other)
    return false unless self.compatible?(other)

    (self.convert_to_base - other.convert_to_base).abs < EPS
  end

  def -(other)
    raise ArgumentError unless self.compatible?(other)

    unit.in_base(self.convert_to_base - other.convert_to_base)
  end

  def inspect
    "#{self.value} #{self.unit.inspect}"
  end

  protected

  def convert_to_base
    unit.convert_to_base(value)
  end

  def compatible?(other)
    Interval === other && self.unit.compatible?(other.unit)
  end
end

class Ratio < Interval
  def +(other)
    raise ArgumentError unless self.compatible?(other)

    unit.in_base(self.convert_to_base + other.convert_to_base)
  end

  def -@
    self.class[-value, unit]
  end
end

class Unit < Struct.new(:name, :base_unit, :multiplier, :offset, :amount_factory)
  protected :name, :multiplier, :base_unit, :offset, :amount_factory

  def initialize(name, base_unit = self, multiplier = 1, offset = 0, amount_factory = Ratio)
    amount_factory = Interval unless offset == 0

    super(name, base_unit, multiplier, offset, amount_factory)

    adjust_to_base_unit if base_unit != self

    install_numeric_extensions(name)
  end

  def convert_to_base(amount)
    amount * multiplier + offset
  end

  def in_base(amount)
    amount_factory[amount, base_unit]
  end

  def compatible?(other)
    self.base_unit == other.base_unit
  end

  def inspect
    name
  end

  private

  def adjust_to_base_unit
    self.multiplier *= base_unit.multiplier
    self.offset += base_unit.offset
    self.base_unit = base_unit.base_unit
  end

  def install_numeric_extensions(name)
    that = self
    factory = amount_factory

    Numeric.class_eval do
      define_method(name) do
        factory[self, that]
      end
    end
  end

  temp = Unit.new(
    :kelvin,
  )

  fahrenheit = Unit.new(
    :fahrenheit,
    temp,
    5 / 9.0,
    -32 / 9.0 * 5.0 + 273.15,
  )

  abs_fahrenheit = Unit.new(
    :abs_fahrenheit,
    temp,
    5 / 9.0,
  )

  abs_kelvin = Unit.new(
    :abs_kelvin,
    temp,
    1.0,
  )

  abs_celsius = Unit.new(
    :abs_celsius,
    temp,
    1.0,
  )

  celsius = Unit.new(
    :celsius,
    temp,
    1,
    273.15,
  )

  teaspoon = Unit.new(:teaspoons)
  tablespoon = Unit.new(:tablespoons, teaspoon, 3)
  ounce = Unit.new(:ounces, tablespoon, 2)
  cup = Unit.new(:cups, ounce, 8)
  pint = Unit.new(:pints, cup, 2)
  quart = Unit.new(:quarts, pint, 2)
  gallon = Unit.new(:gallons, quart, 4)

  inch = Unit.new(:inches)
  foot = Unit.new(:feet, inch, 12)
  yard = Unit.new(:yards, foot, 3)
  mile = Unit.new(:miles, yard, 1760)

  private_class_method :new

end
