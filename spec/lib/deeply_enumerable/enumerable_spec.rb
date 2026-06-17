describe DeeplyEnumerable::Enumerable do
  describe ".deep_rebuild" do
    it "recursively converts nested base collections into DeeplyEnumerable types" do
      rebuilt = DeeplyEnumerable::Array.deep_rebuild([1, [2], { a: 3 }])

      expect(rebuilt).to be_a(DeeplyEnumerable::Array)
      expect(rebuilt[1]).to be_a(DeeplyEnumerable::Array)
      expect(rebuilt[2]).to be_a(DeeplyEnumerable::Hash)
      expect(rebuilt).to eq([1, [2], { a: 3 }])
    end

    it "raises a TypeError when the object is not the expected base class" do
      expect { DeeplyEnumerable::Array.deep_rebuild({}) }.to raise_error(TypeError, /must be a Array/)
    end
  end

  describe ".rebuild" do
    it "returns a DeeplyEnumerable object for a matching base object" do
      expect(DeeplyEnumerable::Array.rebuild([1, 2, 3])).to be_a(DeeplyEnumerable::Array)
    end

    it "returns the object unchanged when no DeeplyEnumerable class matches" do
      expect(DeeplyEnumerable::Array.rebuild("string")).to eq("string")
    end
  end

  describe "#rebuild" do
    it "delegates to the class-level rebuild" do
      array = DeeplyEnumerable::Array.new
      expect(array.rebuild([1])).to be_a(DeeplyEnumerable::Array)
    end
  end

  describe "#deeply_blank? (private)" do
    subject(:array) { DeeplyEnumerable::Array.new }

    [nil, false, "", " ", "\t\n", [], {}].each do |value|
      it "considers #{value.inspect} blank" do
        expect(array.send(:deeply_blank?, value)).to be(true)
      end
    end

    [0, true, "x", [1], { a: 1 }].each do |value|
      it "does not consider #{value.inspect} blank" do
        expect(array.send(:deeply_blank?, value)).to be(false)
      end
    end
  end
end
