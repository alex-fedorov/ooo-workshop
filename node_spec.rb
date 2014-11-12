require 'rspec'
require_relative 'node'

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

  it { expect(b.path_cost(f)).to eq(5) }
  it { expect(b.path_cost(e)).to eq(10) }

  it { expect(b.path_to(f).hop_count).to eq(1) }
  it { expect(b.path_to(f).cost).to eq(5) }

  it { expect(b.path_to(b).hop_count).to eq(0) }
  it { expect(b.path_to(b).cost).to eq(0) }

  it { expect(b.path_to(e).hop_count).to eq(3) }
  it { expect(b.path_to(e).cost).to eq(10) }

  it { expect{ b.path_to(g) }.to raise_error(Node::UnreachableNodeError) }
end
