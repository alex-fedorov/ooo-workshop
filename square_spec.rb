require 'rspec'
require_relative 'square'

RSpec.describe Rectangle do
  it { expect(Rectangle[3, 4].area).to eq(12) }
  it { expect(Rectangle[3, 4].perimeter).to eq(14) }
end

RSpec.describe Square do
  it { expect(Square[6].area).to eq(36) }
  it { expect(Square[6].perimeter).to eq(24) }
end

RSpec.describe 'comparisions' do
  it { expect(Square[3]).to eq(Rectangle[3, 3]) }
  it { expect(Rectangle[3, 3]).to eq(Square[3]) }

  it { expect(Rectangle[3, 4]).to eq(Rectangle[4, 3]) }

  it { expect(Rectangle[3, 4]).not_to eq(Object.new) }
  it { expect(Rectangle[3, 4]).not_to eq(nil) }
end
