describe DeeplyEnumerable::Hash do
  # A tree that exercises every case: surviving values, leaf nils, pre-existing
  # blanks ({}, []), and collections that only become blank through compaction.
  let(:original) do
    {
      a: :b,
      c: nil,
      d: { e: :f, g: nil, h: { i: :j, k: nil, l: [:m], n: [] } },
      o: { p: { q: { r: [nil], s: nil }, t: [], u: nil }, v: [], w: nil },
      x: {},
      y: [],
      z: nil
    }
  end

  describe "#reverse_deep_merge" do
    let(:hash)  { DeeplyEnumerable::Hash.deep_rebuild(a: 1, b: { c: 2 }) }
    let(:other) { { b: { d: 3 }, e: 4 } }

    it "recursively fills in only the keys that are missing" do
      expect(hash.reverse_deep_merge(other)).to eq(a: 1, b: { c: 2, d: 3 }, e: 4)
    end

    it "does not mutate the receiver" do
      expect { hash.reverse_deep_merge(other) }.not_to change { hash.dup }
    end

    it "is aliased as #deep_reverse_merge" do
      expect(hash.deep_reverse_merge(other)).to eq(hash.reverse_deep_merge(other))
    end
  end

  describe "#reverse_deep_merge!" do
    let(:hash) { DeeplyEnumerable::Hash.deep_rebuild(a: 1, b: { c: 2 }) }

    it "merges in place" do
      hash.reverse_deep_merge!(b: { d: 3 }, e: 4)
      expect(hash).to eq(a: 1, b: { c: 2, d: 3 }, e: 4)
    end
  end

  describe "#deep_compact" do
    let(:compact) do
      { a: :b, d: { e: :f, h: { i: :j, l: [:m], n: [] } }, o: { p: { q: { r: [] }, t: [] }, v: [] }, x: {}, y: [] }
    end

    it "recursively removes only nils, keeping every blank collection" do
      expect(DeeplyEnumerable::Hash.deep_compact(original)).to match(compact)
    end

    it "keeps non-nil blank elements such as \"\" and false" do
      expect(DeeplyEnumerable::Hash.deep_compact(a: "", b: false, c: " ", d: nil)).to match(a: "", b: false, c: " ")
    end

    it "does not mutate the original" do
      expect { DeeplyEnumerable::Hash.deep_compact(original) }.not_to change { original.dup }
    end
  end

  describe "#deep_compact!" do
    it "compacts in place and returns self" do
      hash = DeeplyEnumerable::Hash.deep_rebuild(a: 1, b: nil, c: { d: nil })
      expect(hash.deep_compact!).to equal(hash)
      expect(hash).to match(a: 1, c: {})
    end
  end

  describe "#deep_compact_existing_blank" do
    let(:compact) do
      { a: :b, d: { e: :f, h: { i: :j, l: [:m] } }, o: { p: { q: { r: [] } } } }
    end

    it "removes nils and pre-existing blanks, but keeps collections emptied by compaction" do
      expect(DeeplyEnumerable::Hash.deep_compact_existing_blank(original)).to match(compact)
    end

    it "removes blank elements such as \"\", \" \" and false" do
      expect(DeeplyEnumerable::Hash.deep_compact_existing_blank(a: 1, b: "", c: " ", d: false, e: nil)).to match(a: 1)
    end
  end

  describe "#deep_compact_blanked" do
    let(:compact) do
      { a: :b, d: { e: :f, h: { i: :j, l: [:m], n: [] } }, o: { p: { t: [] }, v: [] }, x: {}, y: [] }
    end

    it "removes nils and collections emptied by compaction, but keeps pre-existing blanks" do
      expect(DeeplyEnumerable::Hash.deep_compact_blanked(original)).to match(compact)
    end

    it "keeps pre-existing blank elements such as \"\" and false" do
      expect(DeeplyEnumerable::Hash.deep_compact_blanked(a: "", b: false, c: nil)).to match(a: "", b: false)
    end
  end

  describe "#deep_compact_blank" do
    let(:compact) { { a: :b, d: { e: :f, h: { i: :j, l: [:m] } } } }

    it "recursively removes every blank value" do
      expect(DeeplyEnumerable::Hash.deep_compact_blank(original)).to match(compact)
    end

    it "removes nil, false, blank strings and empty collections" do
      expect(DeeplyEnumerable::Hash.deep_compact_blank(a: 1, b: nil, c: false, d: "", e: " ", f: [], g: {})).to match(a: 1)
    end

    it "is the in-place sibling of #deep_compact_blank!" do
      hash = DeeplyEnumerable::Hash.deep_rebuild(original)
      expect(hash.deep_compact_blank!).to match(DeeplyEnumerable::Hash.deep_compact_blank(original))
    end
  end

  # Documents an intentional v1 -> v2 behavior change: compaction now returns a
  # freshly-built Hash, so a default / default_proc is NOT carried over (matching
  # Hash#reject and Rails' #compact_blank). See the "Upgrading from v1" guide.
  describe "default_proc preservation" do
    it "does not preserve the receiver's default_proc through compaction" do
      accumulator = DeeplyEnumerable::Hash.new { |hash, key| hash[key] = [] }
      accumulator.merge!(a: 1, b: nil)

      result = accumulator.deep_compact_blank

      expect(result.default_proc).to be_nil
      expect(result["missing"]).to be_nil
    end

    it "preserves auto-vivification when the compacted result is merged into a proc-bearing Hash" do
      compacted = DeeplyEnumerable::Hash.deep_compact_blank(a: 1, b: nil)
      result = Hash.new { |hash, key| hash[key] = [] }.merge(compacted)

      expect(result).to eq(a: 1)
      expect(result.default_proc).not_to be_nil
      expect(result["missing"]).to eq([])
    end
  end
end
