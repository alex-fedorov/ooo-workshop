require 'rspec'
require_relative 'chance'
require_relative 'championship'

RSpec.describe Chance do
  it "should understand equality" do
    expect(Chance[0.25]).to eq(Chance[0.25])
    expect(Chance[0.25]).not_to eq(Object.new)
    expect(Chance[0.25]).not_to eq(nil)
    expect(Chance[0.25]).not_to eq('hello')
  end

  it "should be comparable" do
    expect(Chance[0.25].compare(Chance[0.37])).to eq(-1)
    expect(Chance[0.37].compare(Chance[0.25])).to eq(1)
    expect(Chance[0.37].compare(Chance[0.37])).to eq(0)
  end
end

RSpec.describe "List of chances" do
  let(:list) { [ 0.25, 0.12, 0.98, 0.44, 0.67 ] }
  let(:chances) { list.map(&:to_chance) }

  it "is able to find out max" do
    expect(Championship.max(chances)).to eq(Chance[0.98])
  end

  let(:sorted_chances) { list.sort.map(&:to_chance) }

  it "should sort properly" do
    expect(Championship.sort(chances)).to eq(sorted_chances)
  end
end
