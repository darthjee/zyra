shared_examples "a method that returns or create a model" do
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

  context 'when the model has not been registered' do
    it do
      expect { registry.find_or_create(key, attributes) }
        .to raise_error(Zyra::Exceptions::NotRegistered)
    end
  end

  context 'when the model has been registered' do
    before do
      registry.register(model_class, find_by: :email)
    end

    context 'when there is no entry in the database' do
      it do
        expect(registry.find_or_create(key, attributes))
          .to be_a(model_class)
      end

      it do
        expect { registry.find_or_create(key, attributes) }
          .to change(model_class, :count)
      end
    end

    context 'when the entry is there with the same attributes' do
      let!(:user) { create(:user, **attributes) }

      it 'returns the user' do
        expect(registry.find_or_create(key, attributes)).to eq(user)
      end
    end

    context 'when the entry is there with other attributes' do
      let!(:user) { create(:user, email: email) }

      it 'returns the user' do
        expect(registry.find_or_create(key, attributes)).to eq(user)
      end
    end

    context 'when there is another entry' do
      before { create(:user) }

      it 'returns a new model' do
        expect(registry.find_or_create(key, attributes))
          .to be_a(model_class)
      end

      it do
        expect { registry.find_or_create(key, attributes) }
          .to change(model_class, :count)
      end
    end

    context 'when the keys is set as string' do
      let(:keys)  { 'email' }
      let!(:user) { create(:user, **attributes) }

      it 'finds the user the same way' do
        expect(registry.find_or_create(key, attributes)).to eq(user)
      end
    end

    context 'when the attributes have string keys' do
      let(:attributes) { { 'email' => email } }
      let!(:user)      { create(:user, **attributes) }

      it 'finds the user the same way' do
        expect(registry.find_or_create(key, attributes)).to eq(user)
      end
    end

    context 'when there is an event handler and it is triggered' do
      let(:name) { 'new_name' }

      let!(:user) { create(:user, **attributes) }

      before do
        new_name = name

        registry.on(:user, :found) do |model|
          model.update(name: new_name)
        end
      end

      it 'runs the event after the model was found' do
        expect { registry.find_or_create(key, attributes) }
          .to change { user.reload.name }
          .to(name)
      end
    end

    context 'when there is an event handler and it is not triggered' do
      let(:name) { 'new_name' }

      before do
        new_name = name

        registry.on(:user, :found) do |model|
          model.update(name: new_name)
        end
      end

      it do
        expect(registry.find_or_create(key, attributes))
          .to be_a(model_class)
      end

      it do
        expect { registry.find_or_create(key, attributes) }
          .to change(model_class, :count)
      end
    end
  end
end
