class Edge < Struct.new(:node, :costs)
  private :node, :costs

  def _cost(*args, &blk)
    node._cost(*args, &blk) + blk[self]
  end

  def hop_count
    1
  end

  def path_cost
    costs.min
  end
end

class Node < Struct.new(:name)
  Unreachable = Float::INFINITY
  UnreachableNodeError = Class.new(StandardError)

  private :name

  def edge(other, *weigths)
    edges << Edge[other, weigths]
    other
  end

  def can_reach?(other)
    _cost(other, &:hop_count) < Unreachable
  end

  def hop_count(other)
    fails_for_unreachable(_cost(other, &:hop_count))
  end

  def path_cost(other)
    fails_for_unreachable(_cost(other, &:path_cost))
  end

  def inspect
    "#{name}"
  end

  def _cost(other, visited_nodes = [], &blk)
    return 0 if self.eql?(other)
    return Unreachable if visited_nodes.include?(self)
    min(edge_costs(other, visited_nodes_with_self(visited_nodes), &blk))
  end

  private

  def visited_nodes_with_self(visited_nodes)
    visited_nodes.dup << self
  end

  def edge_costs(other, visited_nodes, &blk)
    edges.map { |edge| edge._cost(other, visited_nodes, &blk) }
  end

  def edges
    @_edges ||= []
  end

  def fails_for_unreachable(value)
    raise UnreachableNodeError if value >= Unreachable
    value
  end

  def min(costs)
    costs.min || Unreachable
  end
end
