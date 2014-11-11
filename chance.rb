require_relative 'championship'

class Chance < Struct.new(:value)
  protected :value

  CERTAIN_VALUE = 1.0
  EPSILON = 0.000001

  def ==(other)
    return true if self.equal? other
    return false unless compatible?(other)

    (self.value - other.value).abs < EPSILON
  end

  def compare(other)
    raise ArgumentError unless compatible?(other)
    return Championship::Equal if self == other
    return Championship::Less if self.value < other.value
    Championship::Greater
  end

  private

  def compatible?(other)
    Chance === other
  end
end

Numeric.class_eval do
  def to_chance
    Chance[self]
  end
end
