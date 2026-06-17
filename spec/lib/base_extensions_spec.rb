require "./lib/base_extensions"

describe "base_extensions" do
  describe Hash do
    it "mixes the deep_compact family directly into Hash" do
      expect({ a: 1, b: nil, c: { d: nil, e: 2 }, f: {} }.deep_compact_blank).to eq(a: 1, c: { e: 2 })
    end

    it "adds #reverse_deep_merge to Hash" do
      expect({ a: 1 }.reverse_deep_merge(a: 9, b: 2)).to eq(a: 1, b: 2)
    end
  end

  describe Array do
    it "mixes the deep_compact family directly into Array" do
      expect([1, nil, [nil], [2, nil]].deep_compact_blank).to eq([1, [2]])
    end
  end
end
