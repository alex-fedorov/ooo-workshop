module ValidatableProtectedStruct
  def self.new(*properties)
    klass = Struct.new(*properties) do
      def initialize(*values)
        super
        validate!
      end

      properties.each do |property|
        protected property
      end
    end
  end
end

class Chance < ValidatableProtectedStruct.new(:fraction)
  IMPOSSIBLE = 0
  CERTAINTY_FRACTION = 1

  def validate!
    raise ArgumentError unless (IMPOSSIBLE..CERTAINTY_FRACTION).cover?(fraction)
  end

  def not
    self.class.new(CERTAINTY_FRACTION - fraction)
  end

  def and(other)
    self.class.new(self.fraction * other.fraction)
  end

  def or(other)
    self.not.and(other.not).not
  end
end
