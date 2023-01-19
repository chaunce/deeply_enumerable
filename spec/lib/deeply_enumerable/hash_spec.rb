describe DeeplyEnumerable::Hash do
  describe "#reverse_deep_merge!" do
    it "is true" do
      expect(true).to be true
    end
  end

  describe "#reverse_deep_merge" do
    it "is true" do
      expect(true).to be true
    end
  end

  describe "#deep_compact!" do
    it "is true" do
      expect(true).to be true
    end
  end

  describe "#deep_compact" do
    before(:each) do
    end

    context "with remove_emptied_elements = true" do
      context "and remove_empty_elements = true" do
        let(:original) { { a: :b, c: nil, d: { e: :f, g: nil, h: { i: :j, k: nil, l: [:m], n: [] } }, o: { p: { q: { r: [nil], s: nil }, t: [], u: nil }, v: [], w: nil }, x: {}, y: [], z: nil } }
        let(:compact) { { a: :b, d: { e: :f, h: { i: :j, l: [:m] } } } }

        it "should remove nils, remove empty elements, and remove emptied elements" do
          expect(DeeplyEnumerable::Hash.deep_compact(original, true, true)).to match(compact)
        end
      end

      context "and remove_empty_elements = false" do
        let(:original) { { a: :b, c: nil, d: { e: :f, g: nil, h: { i: :j, k: nil, l: [:m], n: [] } }, o: { p: { q: { r: nil }, s: [nil] }, t: nil }, u: { v: nil, w: {}, x: [], y: [nil], z: nil } } }
        let(:compact) { { a: :b, d: { e: :f, h: { i: :j, l: [:m], n: [] } }, u: { w: {}, x: [] } } }

        it "should remove nils, and remove emptied elements" do
          expect(DeeplyEnumerable::Hash.deep_compact(original, true, false)).to match(compact)
        end
      end
    end

    xcontext "with remove_emptied_elements = false" do
      context "and remove_empty_elements = true" do
        let(:original) { { a: :b, c: nil, d: { e: :f, g: nil, h: { i: :j, k: nil, l: [:m], n: [] } }, o: { p: { q: { r: [nil], s: nil }, t: [], u: nil }, v: [], w: nil }, x: {}, y: [], z: nil } }
        let(:compact) { { a: :b, c: nil, d: { e: :f, g: nil, h: { i: :j, k: nil, l: [:m], n: [] } }, o: { p: { q: { r: [nil], s: nil }, t: [], u: nil }, v: [], w: nil }, x: {}, y: [], z: nil } }

        it "should remove nils, remove empty elements" do
          expect(DeeplyEnumerable::Hash.deep_compact(original)).to match(compact)
        end
      end

      context "and remove_empty_elements = false" do
        let(:original) { { a: :b, c: nil, d: { e: :f, g: nil, h: { i: :j, k: nil, l: [:m], n: [] } }, o: { p: { q: { r: [nil], s: nil }, t: [], u: nil }, v: [], w: nil }, x: {}, y: [], z: nil } }
        let(:compact) { { a: :b, d: { e: :f, h: { i: :j, l: [:m], n: [] } }, o: { p: { q: { r: [] }, t: [] }, v: [] }, x: {}, y: [] } }

        it "should remove nils" do
          expect(DeeplyEnumerable::Hash.deep_compact(original)).to match(compact)
        end
      end
    end
  end
end
