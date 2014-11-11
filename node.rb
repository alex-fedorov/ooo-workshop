class Edge < Struct.new(:node, :costs)
  protected :node, :costs

  def least_cost
    costs.min
  end

  def ==(other)
    return false unless self.class === other
    self.node == other.node
  end

  def eql?(other)
    self.node == other.node
  end

  def hash
    node.hash
  end

  def hop_count(other, visited)
    node._hop_count(other, visited) + 1
  end

  def path_cost(other, visited)
    node._hop_count(other, visited) + 1
  end
end

class Node < Struct.new(:name)
  Unreachable = Float::INFINITY
  UnreachableNodeError = Class.new(StandardError)

  protected :name

  def edge(other, *weigths)
    neighbours << Edge[other, weigths]
    other
  end

  def can_reach?(other)
    _hop_count(other) < Unreachable
  end

  def hop_count(other)
    _hop_count(other).tap do |t|
      raise UnreachableNodeError if t >= Unreachable
    end
  end

  def inspect
    "Node: #{name}"
  end

  def _hop_count(other, visited = [])
    return 0 if self.eql?(other)
    neighbours_hop_counts(other, visited).min || Unreachable
  end

  private

  def unvisited_neighbours(visited)
    neighbours - (visited << Edge[self])
  end

  def neighbours_hop_counts(other, visited)
    unvisited_neighbours(visited).map { |x|
      x.hop_count(other, visited)
    }
  end

  def neighbours
    @_neighbours ||= []
  end
end
