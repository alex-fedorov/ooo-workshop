class Rectangle < Struct.new(:width, :height)
  protected :width, :height

  def area
    width * height
  end

  def perimeter
    2 * (width + height)
  end

  def ==(other)
    return false unless Rectangle === other

    [self.width, self.height].sort == [other.width, other.height].sort
  end
end

class Square < Rectangle
  def initialize(width)
    super(width, width)
  end
end
