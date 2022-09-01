# frozen_string_literal: true

require 'spec_helper'

describe Zyra::Builder do
  subject(:builder) { described_class.new(model_class) }

  let(:model_class) { User }

  describe '#build' do
    it do
      expect(builder.build).to be_a(model_class)
    end

    it do
      expect(builder.build)
        .not_to be_persisted
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

    context 'when building has an after build handler' do
      let(:name) { SecureRandom.hex(10) }

      before do
        value = name
        builder.after(:build) { |model| model.name = value }
      end

      it 'runs the event handler' do
        expect(builder.build.name)
          .to eq(name)
      end
    end
  end

  describe '#create' do
    it do
      expect(builder.create).to be_a(model_class)
    end

    it do
      expect(builder.create)
        .to be_persisted
    end

    context 'when attributes are given' do
      let(:name) { SecureRandom.hex(10) }

      it 'initializes the model with the given attribute' do
        expect(builder.create(name: name).name)
          .to eq(name)
      end
    end

    context 'when a block is given' do
      let(:name) { SecureRandom.hex(10) }

      it 'initializes the model with the given attribute' do
        value = name
        expect(builder.create { |model| model.name = value }.name)
          .to eq(name)
      end
    end

    context 'when building has an after build handler' do
      let(:name) { SecureRandom.hex(10) }

      before do
        value = name
        builder.after(:build) { |model| model.name = value }
      end

      it 'runs the event handler' do
        expect(builder.create.name)
          .to eq(name)
      end
    end
  end

  describe '#after' do
    let(:name) { SecureRandom.hex(10) }

    it 'register a handler to be ran after an event' do
      value = name

      expect { builder.after(:build) { |model| model.name = value } }
        .to change { builder.build.name }
        .from(nil).to(name)
    end

    it do
      expect(builder.after(:build) {})
        .to be(builder)
    end
  end
end
