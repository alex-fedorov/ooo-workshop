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

  def hop_count(*args)
    node._hop_count(*args) + 1
  end

  def path_cost(*args)
    node._path_cost(*args) + least_cost
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
    fails_for_unreachable(_hop_count(other))
  end

  def path_cost(other)
    fails_for_unreachable(_path_cost(other))
  end

  def inspect
    "#{name}"
  end

  def _hop_count(*args)
    _deep_walk(*args, &:hop_count)
  end

  def _path_cost(*args)
    _deep_walk(*args, &:path_cost)
  end

  private

  def _deep_walk(other, visited = [], &blk)
    return 0 if self.eql?(other)
    min(unvisited_neighbours_do(other, visit(visited), &blk))
  end

  def unvisited_neighbours(visited)
    neighbours - visited
  end

  def visit(visited)
    visited.dup << Edge[self]
  end

  def unvisited_neighbours_do(other, visited, &blk)
    unvisited_neighbours(visited).map { |edge| blk[edge, other, visited] }
  end

  def neighbours
    @_neighbours ||= []
  end

  def fails_for_unreachable(value)
    raise UnreachableNodeError if value >= Unreachable
    value
  end

  def min(list)
    list.min || Unreachable
  end
end
