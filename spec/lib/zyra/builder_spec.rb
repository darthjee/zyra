# frozen_string_literal: true

require 'spec_helper'

describe Zyra::Builder do
  subject(:builder) { described_class.new(model_class) }

  let(:model_class) { User }

  describe '#build' do
    it do
      expect(builder.build).to be_a(model_class)
    end

    context 'when attributes are given' do
      let(:name) { SecureRandom.hex(10) }

      it 'initializes the model with the given attribute' do
        expect(builder.build(name: name).name)
          .to eq(name)
      end
    end

    context 'when a block is given' do
      let(:name) { SecureRandom.hex(10) }

      it 'initializes the model with the given attribute' do
        value = name
        expect(builder.build { |model| model.name = value }.name)
          .to eq(name)
      end
    end
  end
end
