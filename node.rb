require_relative 'temperature'

class Edge < Struct.new(:node, :cost)
  private :node, :cost

  def self.total_cost(links)
    links.inject(ZeroRatio.new) { |total, link| link.add_to(total) }
  end

  def add_to(total)
    total + cost
  end

  def _paths_to(*args)
    node._paths_to(*args).map { |path| path << self }
  end
end

class Path
  def self.cheapest(paths)
    paths.inject { |champion, path| path.cheaper?(champion) ? path : champion } || NoPath.new
  end

  def cheaper?(other)
    self.cost < other.cost
  end

  def cost
    Edge.total_cost(links)
  end

  def hop_count
    links.count
  end

  def <<(link)
    links << link
    self
  end

  private

  def links
    @_links ||= []
  end
end

class NoPath
  def <<(link)
    self
  end

  def cheaper?(other)
    false
  end

  def cost
    Float::INFINITY
  end

  def hop_count
    Float::INFINITY
  end
end

class Node < Struct.new(:name)
  Unreachable = Float::INFINITY
  UnreachableNodeError = Class.new(StandardError)

  private :name

  def edge(other, *weigths)
    weigths.each { |weigth| edges << Edge[other, weigth] }
    other
  end

  def can_reach?(other)
    _paths_to(other).any?
  end

  def hop_count(other)
    path_to(other).hop_count
  end

  def path_cost(other)
    path_to(other).cost
  end

  def path_to(other)
    Path.cheapest(fails_for_no_path(_paths_to(other)))
  end

  def paths_to(other)
    _paths_to(other)
  end

  def inspect
    "#{name}"
  end

  def _path_to(other)
    Path.cheapest(_paths_to(other))
  end

  def _paths_to(other, visited_nodes = [])
    return [Path.new] if self.eql?(other)
    return [] if visited_nodes.include?(self)
    all_edge_paths(other, visited_nodes_with_self(visited_nodes))
  end

  private

  def visited_nodes_with_self(visited_nodes)
    visited_nodes.dup << self
  end

  def edge_paths(other, visited_nodes)
    edges.map { |edge| edge._path_to(other, visited_nodes) }
  end

  def all_edge_paths(other, visited_nodes)
    edges.map { |edge| edge._paths_to(other, visited_nodes.dup) }.inject(&:+) || []
  end

  def edges
    @_edges ||= []
  end

  def fails_for_no_path(paths)
    raise UnreachableNodeError if paths.empty?
    paths
  end
end
