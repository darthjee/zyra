# frozen_string_literal: true

require 'spec_helper'

describe Zyra do
  before { described_class.reset }

  describe '.build' do
    let(:model_class) { User }
    let(:key)         { :user }

    context 'when a builder has not been registered' do
      it do
        expect { described_class.build(key) }
          .to raise_error(Zyra::Exceptions::BuilderNotRegistered)
      end
    end

    context 'when a builder has been registered' do
      before do
        described_class.register(model_class, find_by: :email)
      end

      it do
        expect(described_class.build(key)).to be_a(model_class)
      end

      it do
        expect(described_class.build(key))
          .not_to be_persisted
      end

      context 'when attributes are given' do
        let(:name) { SecureRandom.hex(10) }

        it 'initializes the model with the given attribute' do
          expect(described_class.build(key, name: name).name)
            .to eq(name)
        end
      end

      context 'when a block is given' do
        let(:name) { SecureRandom.hex(10) }

        it 'initializes the model with the given attribute' do
          value = name
          expect(described_class.build(key) { |model| model.name = value }.name)
            .to eq(name)
        end
      end

      context 'when building has an after build handler' do
        let(:name) { SecureRandom.hex(10) }

        before do
          value = name
          described_class.after(:user, :build) do |model|
            model.name = value
          end
        end

        it 'runs the event handler' do
          expect(described_class.build(key) .name)
            .to eq(name)
        end
      end
    end
  end

  describe '.create' do
    let(:model_class) { User }
    let(:key)         { :user }

    context 'when a builder has not been registered' do
      it do
        expect { described_class.create(key) }
          .to raise_error(Zyra::Exceptions::BuilderNotRegistered)
      end
    end

    context 'when a builder has been registered' do
      before do
        described_class.register(model_class, find_by: :email)
      end

      it do
        expect(described_class.create(key)).to be_a(model_class)
      end

      it do
        expect(described_class.create(key))
          .to be_persisted
      end

      context 'when attributes are given' do
        let(:name) { SecureRandom.hex(10) }

        it 'initializes the model with the given attribute' do
          expect(described_class.create(key, name: name).name)
            .to eq(name)
        end
      end

      context 'when a block is given' do
        let(:name) { SecureRandom.hex(10) }

        it 'initializes the model with the given attribute' do
          value = name
          model = described_class.create(key) { |mdl| mdl.name = value }
          expect(model.name)
            .to eq(name)
        end
      end

      context 'when building has an after build handler' do
        let(:name) { SecureRandom.hex(10) }

        before do
          value = name
          described_class.after(:user, :build) do |model|
            model.name = value
          end
        end

        it 'runs the event handler' do
          expect(described_class.create(key) .name)
            .to eq(name)
        end
      end
    end
  end

  describe '.after' do
    let(:model_class) { User }
    let(:key)         { :user }
    let(:name)        { SecureRandom.hex(10) }

    context 'when a builder has been registered' do
      before do
        described_class.register(model_class, find_by: :email)
      end

      it 'register a handler to be ran after an event' do
        value = name

        expect { described_class.after(key, :build) { |m| m.name = value } }
          .to change { described_class.build(key).name }
          .from(nil).to(name)
      end

      it do
        expect(described_class.after(key, :build) {})
          .to be_a(Zyra::FinderCreator)
      end
    end
  end

  describe '.find_or_create' do
    let(:key)         { :user }
    let(:email)       { SecureRandom.hex(10) }
    let(:model_class) { User }

    let(:attributes) do
      {
        name: 'Some Name',
        email: email,
        password: 'SomePassword'
      }
    end

    context 'when the model has been registered' do
      before do
        described_class.register(model_class, find_by: :email)
      end

      context 'when there is no entry in the database' do
        it do
          expect(described_class.find_or_create(key, attributes))
            .to be_a(model_class)
        end

        it do
          expect { described_class.find_or_create(key, attributes) }
            .to change(model_class, :count)
        end
      end

      context 'when the entry is there with the same attributes' do
        let!(:user) { create(:user, **attributes) }

        it 'returns the user' do
          expect(described_class.find_or_create(key, attributes)).to eq(user)
        end
      end

      context 'when the entry is there with other attributes' do
        let!(:user) { create(:user, email: email) }

        it 'returns the user' do
          expect(described_class.find_or_create(key, attributes)).to eq(user)
        end
      end

      context 'when there is another entry' do
        before { create(:user) }

        it 'returns a new model' do
          expect(described_class.find_or_create(key, attributes))
            .to be_a(model_class)
        end

        it do
          expect { described_class.find_or_create(key, attributes) }
            .to change(model_class, :count)
        end
      end

      context 'when the keys is set as string' do
        let(:keys)  { 'email' }
        let!(:user) { create(:user, **attributes) }

        it 'finds the user the same way' do
          expect(described_class.find_or_create(key, attributes)).to eq(user)
        end
      end

      context 'when the attributes have string keys' do
        let(:attributes) { { 'email' => email } }
        let!(:user)      { create(:user, **attributes) }

        it 'finds the user the same way' do
          expect(described_class.find_or_create(key, attributes)).to eq(user)
        end
      end

      context 'when there is an event handler and it is triggered' do
        let(:name) { 'new_name' }

        let!(:user) { create(:user, **attributes) }

        before do
          new_name = name

          described_class.after(:user, :found) do |model|
            model.update(name: new_name)
          end
        end

        it 'runs the event after the model was found' do
          expect { described_class.find_or_create(key, attributes) }
            .to change { user.reload.name }
            .to(name)
        end
      end

      context 'when there is an event handler and it is not triggered' do
        let(:name) { 'new_name' }

        before do
          new_name = name

          described_class.after(:user, :found) do |model|
            model.update(name: new_name)
          end
        end

        it do
          expect(described_class.find_or_create(key, attributes))
            .to be_a(model_class)
        end

        it do
          expect { described_class.find_or_create(key, attributes) }
            .to change(model_class, :count)
        end
      end
    end
  end
end
