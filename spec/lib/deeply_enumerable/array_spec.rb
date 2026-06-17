describe DeeplyEnumerable::Array do
  # Top-level elements covering survivors, a nil leaf, pre-existing blanks,
  # a collection emptied by compaction, and a nested hash.
  let(:original) { [1, nil, "", false, [nil], [1, nil], {}, { a: nil }, { b: 2 }] }

  describe "#deep_compact" do
    it "recursively removes only nils, keeping every blank element" do
      expect(DeeplyEnumerable::Array.deep_compact(original)).to match([1, "", false, [], [1], {}, {}, { b: 2 }])
    end

    it "does not mutate the original" do
      expect { DeeplyEnumerable::Array.deep_compact(original) }.not_to change { original.dup }
    end
  end

  describe "#deep_compact!" do
    it "compacts in place and returns self" do
      array = DeeplyEnumerable::Array.deep_rebuild([1, nil, [nil]])
      expect(array.deep_compact!).to equal(array)
      expect(array).to match([1, []])
    end
  end

  describe "#deep_compact_existing_blank" do
    it "removes nils and pre-existing blanks, but keeps elements emptied by compaction" do
      expect(DeeplyEnumerable::Array.deep_compact_existing_blank(original)).to match([1, [], [1], {}, { b: 2 }])
    end
  end

  describe "#deep_compact_blanked" do
    it "removes nils and collections emptied by compaction, but keeps pre-existing blanks" do
      expect(DeeplyEnumerable::Array.deep_compact_blanked(original)).to match([1, "", false, [1], {}, { b: 2 }])
    end
  end

  describe "#deep_compact_blank" do
    it "recursively removes every blank element" do
      expect(DeeplyEnumerable::Array.deep_compact_blank(original)).to match([1, [1], { b: 2 }])
    end

    it "is the in-place sibling of #deep_compact_blank!" do
      array = DeeplyEnumerable::Array.deep_rebuild(original)
      expect(array.deep_compact_blank!).to match(DeeplyEnumerable::Array.deep_compact_blank(original))
    end
  end
end
