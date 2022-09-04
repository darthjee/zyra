# frozen_string_literal: true

require 'spec_helper'

describe Zyra::Registry do
  let(:registry) { described_class.new }

  describe '#register' do
    context 'when providing symbol alias' do
      let(:key) { :user_alias }

      it 'creates a builder for the given class' do
        expect(registry.register(User, key))
          .to eq(Zyra::FinderCreator.new(User, []))
      end

      it 'register builder under the key' do
        expect { registry.register(User, key) }
          .to change { registry.finder_creator_for(key) }
          .from(nil).to(Zyra::FinderCreator.new(User, []))
      end
    end

    context 'when providing string alias' do
      let(:key) { 'user' }

      it 'creates a builder for the given class' do
        expect(registry.register(User, key))
          .to eq(Zyra::FinderCreator.new(User, []))
      end

      it 'register builder under the key' do
        expect { registry.register(User, key) }
          .to change { registry.finder_creator_for(key) }
          .from(nil).to(Zyra::FinderCreator.new(User, []))
      end
    end

    context 'when not providing an alias' do
      let(:key) { :user }

      it 'creates a builder for the given class' do
        expect(registry.register(User))
          .to eq(Zyra::FinderCreator.new(User, []))
      end

      it 'register builder under the correct key' do
        expect { registry.register(User) }
          .to change { registry.finder_creator_for(key) }
          .from(nil).to(Zyra::FinderCreator.new(User, []))
      end
    end
  end

  describe '#finder_creator_for' do
    let(:key) { :user }

    context 'when there is no builder registered' do
      it do
        expect(registry.finder_creator_for(key))
          .to be_nil
      end
    end

    context 'when there is no builder registered on a symbol key' do
      before do
        registry.register(User, :user)
      end

      it do
        expect(registry.finder_creator_for(key))
          .to eq(Zyra::FinderCreator.new(User, []))
      end

      context 'when passing a string key' do
        let(:key) { 'user' }

        it do
          expect(registry.finder_creator_for(key))
            .to eq(Zyra::FinderCreator.new(User, []))
        end
      end
    end

    context 'when there is no builder registered on a string key' do
      before do
        registry.register(User, 'user')
      end

      it do
        expect(registry.finder_creator_for(key))
          .to eq(Zyra::FinderCreator.new(User, []))
      end

      context 'when passing a string key' do
        let(:key) { 'user' }

        it do
          expect(registry.finder_creator_for(key))
            .to eq(Zyra::FinderCreator.new(User, []))
        end
      end
    end
  end
end
