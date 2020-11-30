Spectator.describe String do
  include StringHelpers

  describe "#size" do
    subject { random_string(10).size }

    it "is the length of the string" do
      is_expected.to eq(10)
    end
  end
end

Spectator.describe String do
  include StringHelpers

  describe "#size" do
    let(length) { 10 } # random_string uses this.
    subject { random_string.size }

    it "is the length of the string" do
      is_expected.to eq(length)
    end
  end
end
