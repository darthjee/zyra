# frozen_string_literal: true

require 'spec_helper'

describe Zyra::Registry do
  let(:registry) { described_class.new }

  describe '#register' do
    it do
      expect(registry.register(User, as: :user))
        .to be_a(Zyra::Builder)
    end

    it 'creates a builder for the given class' do
      expect(registry.register(User, as: :user))
        .to eq(Zyra::Builder.new(User))
    end

    it 'register builder under the key' do
      expect { registry.register(User, as: :user) }
        .to change { registry.builder_for(:user) }
        .from(nil).to(Zyra::Builder.new(User))
    end

    context 'when not providing an alias' do
      it do
        expect(registry.register(User))
          .to be_a(Zyra::Builder)
      end

      it 'creates a builder for the given class' do
        expect(registry.register(User))
          .to eq(Zyra::Builder.new(User))
      end

      it 'register builder under the correct key' do
        expect { registry.register(User) }
          .to change { registry.builder_for(:user) }
          .from(nil).to(Zyra::Builder.new(User))
      end
    end
  end
end
