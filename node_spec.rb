require 'rspec'
require_relative 'node'

RSpec.describe 'Edge' do
  it { expect(Edge[Node[:a], [1, 2, 3]]).to eq(Edge[Node[:a]]) }
  it { expect(Edge[Node[:a], [1, 2, 3]]).not_to eq(Edge[Node[:b]]) }
  it { expect(Edge[Node[:a], [1, 2, 3]]).not_to eq(Object.new) }
  it { expect(Edge[Node[:a], [1, 2, 3]]).not_to eq(nil) }
  it { expect(Edge[Node[:a], [1, 2, 3]]).not_to eq("a string") }

  it { expect(Edge[Node[:a], [1, 2, 3]].hash).to eq(Edge[Node[:a]].hash) }

  it nil, :focus do
    expect([Edge[Node[:a]], Edge[Node[:b]], Edge[Node[:c]]] -
      [Edge[Node[:a]], Edge[Node[:c]]]).to eq([Edge[Node[:b]]])

    expect([Edge[Node[:a], [3, 4]], Edge[Node[:b], [5]], Edge[Node[:c], [1]]] -
      [Edge[Node[:a], [0]], Edge[Node[:c], [1]]]).to eq([Edge[Node[:b]]])
  end
end

RSpec.describe 'Node' do
  let(:a) { Node[:a] }
  let(:b) { Node[:b] }
  let(:c) { Node[:c] }
  let(:d) { Node[:d] }
  let(:e) { Node[:e] }
  let(:f) { Node[:f] }
  let(:g) { Node[:g] }

  before do
    b.edge(a, 6)
    b.edge(c, 7).edge(d, 3, 1).edge(e, 2).edge(b, 4).edge(f, 5)
    c.edge(e, 8)
  end

  it { expect(b).to be_can_reach(e) }
  it { expect(a).not_to be_can_reach(e) }
  it { expect(b).not_to be_can_reach(g) }

  it { expect(d.hop_count(f)).to eq(3) }
  it { expect(b.hop_count(b)).to eq(0) }
  it { expect{ b.hop_count(g) }.to raise_error(Node::UnreachableNodeError) }
end
