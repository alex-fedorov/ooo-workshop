require 'rspec'
require_relative 'node'
require_relative 'temperature'

RSpec.describe 'Node' do
  let(:a) { Node[:a] }
  let(:b) { Node[:b] }
  let(:c) { Node[:c] }
  let(:d) { Node[:d] }
  let(:e) { Node[:e] }
  let(:f) { Node[:f] }
  let(:g) { Node[:g] }

  before do
    b.edge(a, 6.inches)
    b.edge(c, 7.inches).edge(d, 3.miles, 1.inches).edge(e, 2.inches).edge(b, 4.inches).edge(f, 5.inches)
    c.edge(e, 8.inches)
  end

  it { expect(b).to be_can_reach(e) }
  it { expect(a).not_to be_can_reach(e) }
  it { expect(b).not_to be_can_reach(g) }

  it { expect(d.hop_count(f)).to eq(3) }
  it { expect(b.hop_count(b)).to eq(0) }
  it { expect{ b.hop_count(g) }.to raise_error(Node::UnreachableNodeError) }

  it { expect(b.path_cost(f)).to eq(5.inches) }
  it { expect(b.path_cost(e)).to eq(10.inches) }

  it { expect(b.path_to(f).hop_count).to eq(1) }
  it { expect(b.path_to(f).cost).to eq(5.inches) }

  it { expect(b.path_to(b).hop_count).to eq(0) }
  it { expect(b.path_to(b).cost).to eq(0.inches) }

  it { expect(b.path_to(e).hop_count).to eq(3) }
  it { expect(b.path_to(e).cost).to eq(10.inches) }

  it { expect{ b.path_to(g) }.to raise_error(Node::UnreachableNodeError) }

  it { expect(b.paths_to(e).count).to eq(3) }
  it { expect(b.paths_to(e).map(&:cost)).to eq([190089.inches, 10.inches, 15.inches]) }

  it { expect(b.paths_to(g)).to eq([]) }
  it { expect(b.paths_to(b).map(&:hop_count)).to eq([0]) }
end
