# frozen_string_literal: true

require 'spec_helper'

describe Zyra::Registry do
  let(:registry) { described_class.new }

  describe '#register' do
    context 'when providing symbol alias' do
      let(:key) { :user_alias }

      it 'creates a builder for the given class' do
        expect(registry.register(User, as: key))
          .to eq(Zyra::Builder.new(User))
      end

      it 'register builder under the key' do
        expect { registry.register(User, as: key) }
          .to change { registry.builder_for(key) }
          .from(nil).to(Zyra::Builder.new(User))
      end
    end

    context 'when providing string alias' do
      let(:key) { 'user' }

      it 'creates a builder for the given class' do
        expect(registry.register(User, as: key))
          .to eq(Zyra::Builder.new(User))
      end

      it 'register builder under the key' do
        expect { registry.register(User, as: key) }
          .to change { registry.builder_for(key) }
          .from(nil).to(Zyra::Builder.new(User))
      end
    end

    context 'when not providing an alias' do
      let(:key) { :user }

      it 'creates a builder for the given class' do
        expect(registry.register(User))
          .to eq(Zyra::Builder.new(User))
      end

      it 'register builder under the correct key' do
        expect { registry.register(User) }
          .to change { registry.builder_for(key) }
          .from(nil).to(Zyra::Builder.new(User))
      end
    end
  end

  describe '#builder_for' do
    let(:key) { :user }

    context 'when there is no builder registered' do
      it do
        expect(registry.builder_for(key))
          .to be_nil
      end
    end

    context 'when there is no builder registered on a symbol key' do
      before do
        expect(registry.register(User, as: :user))
      end

      it do
        expect(registry.builder_for(key))
          .to eq(Zyra::Builder.new(User))
      end

      context 'when passing a string key' do
        let(:key) { 'user' }

        it do
          expect(registry.builder_for(key))
            .to eq(Zyra::Builder.new(User))
        end
      end
    end

    context 'when there is no builder registered on a string key' do
      before do
        expect(registry.register(User, as: 'user'))
      end

      it do
        expect(registry.builder_for(key))
          .to eq(Zyra::Builder.new(User))
      end

      context 'when passing a string key' do
        let(:key) { 'user' }

        it do
          expect(registry.builder_for(key))
            .to eq(Zyra::Builder.new(User))
        end
      end
    end
  end
end
