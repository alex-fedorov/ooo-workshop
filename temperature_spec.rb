require 'rspec'
require_relative 'championship'
require_relative 'temperature'

RSpec.describe 'Temperatures' do
  describe 'Simple conversions' do
    it { expect(20.celsius).to eq(293.15.kelvin) }
    it { expect(55.fahrenheit).to eq(285.92777777777775.kelvin) }

    it { expect(0.celsius).to eq(32.fahrenheit) }
    it { expect(32.fahrenheit).to eq(0.celsius) }
    it { expect(31.fahrenheit).to eq(-0.55555555555555.celsius) }
    it { expect(32.fahrenheit).to eq(0.celsius) }

    it { expect(100.celsius).to eq(212.fahrenheit) }
    it { expect(212.fahrenheit).to eq(100.celsius) }
  end

  describe 'Comparisions' do
    it { expect(3.celsius).not_to eq(Object.new) }
    it { expect(3.celsius).not_to eq(nil) }
    it { expect(3.celsius).not_to eq(5.fahrenheit) }
    it { expect(3.celsius).to eq(3.celsius) }

    it { expect(2.celsius).to be > 15.fahrenheit }
  end

  describe 'Addition' do
    it { expect { 100.celsius + 212.abs_fahrenheit }.to raise_error }
    it { expect(212.abs_fahrenheit + 100.celsius).to eq(217.777777777777777.celsius) }

    it { expect { 212.fahrenheit + 100.abs_celsius }.to raise_error }
    it { expect(100.abs_celsius + 212.fahrenheit).to eq(200.celsius) }

    it { expect { 100.celsius + 212.abs_fahrenheit }.to raise_error }

    it { expect { 100.celsius + 212.fahrenheit }.to raise_error }
  end

  describe 'Subtraction' do
    it { expect(100.celsius - 50.celsius).to eq(50.abs_celsius) }
    it { expect(100.celsius - 50.abs_celsius).to eq(50.celsius) }
  end
end

RSpec.describe "1st order unit conversions" do

  it "should understand equality of same unit" do
    expect(3.tablespoons).to eq(3.tablespoons)
    expect(3.feet).to eq(3.feet)
    expect(3.tablespoons).not_to eq(Object.new)
    expect(3.tablespoons).not_to eq(nil)
  end

  it 'should understand equality across different units' do
    expect(1.tablespoons).to eq(3.teaspoons)
    expect(0.5.gallons).to eq(8.cups)
    expect(8.cups).to eq(0.5.gallons)
    expect(9.feet).to eq(3.yards)
    expect(2.yards).to eq(72.inches)
  end

  it 'should prohibit creation of new Units' do
    expect { Unit.new }.to raise_error(NoMethodError)
  end

  it 'should support arithmetic' do
    expect(-(2.tablespoons)).to eq(-2.tablespoons)
    expect(7.tablespoons + 3.teaspoons).to eq(0.5.cups)
    expect(0.5.cups - 3.teaspoons).to eq(7.tablespoons)
    expect(2.yards - 2.feet - 24.inches).to eq(2.feet)
  end

  it 'should forbid cross-unit-type equality' do
    expect(1.feet).not_to eq(2.ounces)
  end

  it 'should reject cross-unit-type arithmetic' do
    expect { 2.feet + 3.ounces }.to raise_error(ArgumentError)
  end

end

RSpec.describe "Championship for unit" do
  let(:some_units) { [11.teaspoons, 3.tablespoons, 1.quarts, 4.teaspoons, 3.pints] }
  let(:bad_list) { [11.teaspoons, 3.inches, 1.quarts, 4.teaspoons, 3.pints] }
  let(:sorted_units) { [4.teaspoons, 3.tablespoons, 11.teaspoons, 1.quarts, 3.pints] }

  it { expect(Championship.sort(some_units)).to eq(sorted_units) }
  it { expect(Championship.max(some_units)).to eq(3.pints) }

  it { expect { Championship.max(bad_list) }.to raise_error }
end
