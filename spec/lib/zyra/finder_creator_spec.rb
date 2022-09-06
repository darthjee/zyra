# frozen_string_literal: true

require 'spec_helper'

describe Zyra::FinderCreator do
  subject(:finder) do
    described_class.new(model_class, keys)
  end

  let(:event_registry) { Jace::Registry.new }
  let(:model_class)    { User }
  let(:keys)           { :email }
  let(:email)          { SecureRandom.hex(10) }

  describe '#find_or_create' do
    let(:attributes) do
      {
        name: 'Some Name',
        email: email,
        password: 'SomePassword'
      }
    end

    context 'when there is no entry in the database' do
      it do
        expect(finder.find_or_create(attributes)).to be_a(model_class)
      end

      it do
        expect { finder.find_or_create(attributes) }
          .to change(model_class, :count)
      end

      context 'when a block is given' do
        it do
          user = finder.find_or_create(attributes) do |u|
            u.update(name: 'new name')
          end

          expect(user.name).to eq('new name')
        end
      end
    end

    context 'when the entry is there with the same attributes' do
      let!(:user) { create(:user, **attributes) }

      it 'returns the user' do
        expect(finder.find_or_create(attributes)).to eq(user)
      end
    end

    context 'when the entry is there with other attributes' do
      let!(:user) { create(:user, email: email) }

      it 'returns the user' do
        expect(finder.find_or_create(attributes)).to eq(user)
      end
    end

    context 'when there is another entry' do
      before { create(:user) }

      it 'returns a new model' do
        expect(finder.find_or_create(attributes)).to be_a(model_class)
      end

      it do
        expect { finder.find_or_create(attributes) }
          .to change(model_class, :count)
      end
    end

    context 'when the keys is set as string' do
      let(:keys)  { 'email' }
      let!(:user) { create(:user, **attributes) }

      it 'finds the user the same way' do
        expect(finder.find_or_create(attributes)).to eq(user)
      end
    end

    context 'when the attributes have string keys' do
      let(:attributes) { { 'email' => email } }
      let!(:user)      { create(:user, **attributes) }

      it 'finds the user the same way' do
        expect(finder.find_or_create(attributes)).to eq(user)
      end
    end

    context 'when there is an event handler on found' do
      let(:name) { 'new_name' }

      before do
        new_name = name

        finder.on(:found) do |model|
          model.update(name: new_name)
        end
      end

      context 'when the model is found' do
        let!(:user) { create(:user, **attributes) }

        it 'runs the event after the model was found' do
          expect { finder.find_or_create(attributes) }
            .to change { user.reload.name }
            .to(name)
        end

        it do
          expect { finder.find_or_create(attributes) }
            .not_to change(model_class, :count)
        end
      end

      context 'when the model is not found' do
        it 'does not run the event after the model was found' do
          expect(finder.find_or_create(attributes).name)
            .not_to eq(name)
        end

        it do
          expect(finder.find_or_create(attributes)).to be_a(model_class)
        end

        it do
          expect { finder.find_or_create(attributes) }
            .to change(model_class, :count)
        end
      end
    end

    context 'when there is an event handler on build' do
      let(:name) { 'new_name' }

      before do
        new_name = name

        finder.on(:build) do |model|
          model.name = new_name
        end
      end

      context 'when the model is found' do
        let!(:user) { create(:user, **attributes) }

        it 'does not run the event after the model was found' do
          expect { finder.find_or_create(attributes) }
            .not_to change { user.reload.name }
        end
      end

      context 'when the model is not found' do
        it 'runs the event after the model was build' do
          expect(finder.find_or_create(attributes).reload.name)
            .to eq(name)
        end

        it do
          expect(finder.find_or_create(attributes)).to be_a(model_class)
        end

        it do
          expect { finder.find_or_create(attributes) }
            .to change(model_class, :count)
        end
      end
    end

    context 'when there is an event handler on create' do
      let(:name) { 'new_name' }

      before do
        new_name = name

        finder.on(:create) do |model|
          model.name = new_name
        end
      end

      context 'when the model is found' do
        before { create(:user, **attributes) }

        it 'does not run the event after the model was found' do
          expect(finder.find_or_create(attributes).name)
            .not_to eq(name)
        end
      end

      context 'when the model is not found' do
        it 'runs the event after the model was created' do
          expect(finder.find_or_create(attributes).name)
            .to eq(name)
        end

        it 'does not run the event after the model was build' do
          expect(finder.find_or_create(attributes).reload.name)
            .not_to eq(name)
        end

        it do
          expect(finder.find_or_create(attributes)).to be_a(model_class)
        end

        it do
          expect { finder.find_or_create(attributes) }
            .to change(model_class, :count)
        end
      end
    end

    context 'when there is an event handler on return' do
      let(:name) { 'new_name' }

      before do
        new_name = name

        finder.on(:return) do |model|
          model.update(name: new_name)
        end
      end

      context 'when the model is found' do
        let!(:user) { create(:user, **attributes) }

        it 'does not run the event after the model was found' do
          expect { finder.find_or_create(attributes) }
            .to change { user.reload.name }
        end
      end

      context 'when the model is not found' do
        it 'runs the event after the model was returned' do
          expect(finder.find_or_create(attributes).reload.name)
            .to eq(name)
        end

        it do
          expect(finder.find_or_create(attributes)).to be_a(model_class)
        end

        it do
          expect { finder.find_or_create(attributes) }
            .to change(model_class, :count)
        end
      end
    end
  end
end
