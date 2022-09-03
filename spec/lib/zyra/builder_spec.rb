# frozen_string_literal: true

require 'spec_helper'

describe Zyra::Builder do
  subject(:builder) do
    described_class.new(model_class, event_registry: event_registry) 
  end

  let(:event_registry) { Jace::Registry.new }
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
        event_registry.register(:build) { |model| model.name = value }
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
        event_registry.register(:build) { |model| model.name = "#{value}#{model.id}" }
      end

      it 'runs the event handler' do
        expect(builder.create.name)
          .to eq(name)
      end
    end

    context 'when building has an after create handler' do
      let(:name) { SecureRandom.hex(10) }

      before do
        value = name
        event_registry.register(:create) { |model| model.name = "#{value}#{model.id}" }
      end

      it 'runs the event handler' do
        model = builder.create
        expect(model.name)
          .to eq("#{name}#{model.id}")
      end
    end
  end
end
