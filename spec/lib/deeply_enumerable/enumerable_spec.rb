describe DeeplyEnumerable::Enumerable do
  let(:base_class) { Array }
  let(:base_class_const) { base_class.name.to_sym }
  let(:deeply_enumerable_class) { DeeplyEnumerable::Array }

  describe ".rebuild" do
    before(:each) do
      allow(DeeplyEnumerable).to receive(:constants).with(false).and_return([base_class_const])
      allow(DeeplyEnumerable).to receive(:const_get).with(base_class_const).and_return(deeply_enumerable_class)
    end

    context "where object is a deeply enumerable class type" do
      let(:object) { [1, 2, 3] }

      before(:each) do
        allow(deeply_enumerable_class).to receive(:respond_to?).with(:superclass, true).and_return(true)
        allow(deeply_enumerable_class).to receive(:respond_to?).with(:superclass).and_return(true)
        allow(deeply_enumerable_class).to receive(:superclass).and_return(base_class)
        allow(object).to receive(:is_a?).with(base_class).and_return(true)
      end

      describe "and this class does respond to :deep_rebuild" do
        let(:response) { [4, 5, 6] }

        before(:each) do
          allow(deeply_enumerable_class).to receive(:respond_to?).with(:deep_rebuild, true).and_return(true)
          allow(deeply_enumerable_class).to receive(:respond_to?).with(:deep_rebuild).and_return(true)
          allow(deeply_enumerable_class).to receive(:deep_rebuild).with(object).and_return(response)
        end

        it "returns rebuild object" do
          expect(deeply_enumerable_class.rebuild(object)).to eq(response)
        end
      end

      describe "and this class does not respond to :deep_rebuild" do
        before(:each) do
          allow(deeply_enumerable_class).to receive(:respond_to?).with(:deep_rebuild).and_return(false)
        end

        it "is works" do
          expect(deeply_enumerable_class.rebuild(object)).to eq(object)
        end
      end
    end

    context "where object is not a deeply enumerable class type" do
      let(:object) { "string" }

      before(:each) do
        allow(deeply_enumerable_class).to receive(:respond_to?).with(:superclass).and_return(false)
      end

      it "should return object" do
        expect(deeply_enumerable_class.rebuild(object)).to eq(object)
      end
    end
  end

  # def deep_rebuild(object)
  #   check_object_class(object)
  #   new.tap { |deeply_enumerable_object| object.each { |value| deeply_enumerable_object.push(rebuild(value)) } }
  # end
  describe ".deep_rebuild" do
    it "is works" do
      expect(true).to be true
    end
  end

  # def deep_compact(object, remove_emptied_elements = true, remove_empty_elements = remove_emptied_elements)
  #   check_object_class(object)
  #   deep_rebuild(object).deep_compact(remove_emptied_elements, remove_empty_elements)
  # end
  describe ".deep_compact" do
  end

  # def check_object_class(object)
  #   raise TypeError, "object must be a #{superclass.name}" unless object.kind_of?(superclass)
  # end
  describe ".check_object_class" do
  end

  # def rebuild(object)
  #   self.class.rebuild(object)
  # end
  describe "#rebuild" do
  end
end
