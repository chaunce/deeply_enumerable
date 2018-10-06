describe DeeplyEnumerable::Enumerable do
  describe '.constants' do
    it 'should return all deeply enumerable classes' do
      expect(DeeplyEnumerable.constants(false)).to include(*%i[Array Hash])
    end
  end
end
