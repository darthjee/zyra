# frozen_string_literal: true

require 'spec_helper'

describe Zyra::Registry do
  let(:registry) { described_class.new }

  describe '#register' do
    let(:recovery_key) { [key.to_s, key.to_sym].sample }
    let(:attributes)   { { email: 'email@srv.com' } }

    context 'when providing symbol alias' do
      let(:key) { :user_alias }

      it 'creates a creator for the given class' do
        expect(registry.register(User, key, find_by: :email))
          .to eq(Zyra::FinderCreator.new(User, [:email]))
      end

      it 'register creator under the key' do
        registry.register(User, key, find_by: :email)

        expect(registry.find_or_create(recovery_key, attributes))
          .to be_a(User)
      end
    end

    context 'when providing string alias' do
      let(:key) { 'user' }

      it 'creates a creator for the given class' do
        expect(registry.register(User, key, find_by: :email))
          .to eq(Zyra::FinderCreator.new(User, [:email]))
      end

      it 'register creator under the key' do
        registry.register(User, key, find_by: :email)

        expect(registry.find_or_create(recovery_key, attributes))
          .to be_a(User)
      end
    end

    context 'when not providing an alias' do
      let(:key) { :user }

      it 'creates a creator for the given class' do
        expect(registry.register(User, find_by: :email))
          .to eq(Zyra::FinderCreator.new(User, [:email]))
      end

      it 'register creator under the correct key' do
        registry.register(User, key, find_by: :email)

        expect(registry.find_or_create(recovery_key, attributes))
          .to be_a(User)
      end
    end
  end

  describe '#finder_creator_for' do
    let(:key) { :user }

    context 'when there is no creator registered' do
      it do
        expect { registry.finder_creator_for(key) }
          .to raise_error(Zyra::Exceptions::CreatorNotRegistered)
      end
    end

    context 'when there is no creator registered on a symbol key' do
      before do
        registry.register(User, :user, find_by: :email)
      end

      it do
        expect(registry.finder_creator_for(key))
          .to eq(Zyra::FinderCreator.new(User, [:email]))
      end

      context 'when passing a string key' do
        let(:key) { 'user' }

        it do
          expect(registry.finder_creator_for(key))
            .to eq(Zyra::FinderCreator.new(User, [:email]))
        end
      end
    end

    context 'when there is no creator registered on a string key' do
      before do
        registry.register(User, 'user', find_by: :email)
      end

      it do
        expect(registry.finder_creator_for(key))
          .to eq(Zyra::FinderCreator.new(User, [:email]))
      end

      context 'when passing a string key' do
        let(:key) { 'user' }

        it do
          expect(registry.finder_creator_for(key))
            .to eq(Zyra::FinderCreator.new(User, [:email]))
        end
      end
    end
  end
end
