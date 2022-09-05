shared_examples "a method that registers an event handler" do
  let(:model_class) { User }
  let(:key)         { :user }
  let(:name)        { SecureRandom.hex(10) }

  let(:attributes) do
    {
      name: 'Some Name',
      email: 'someemail@srv.com',
      password: 'SomePassword'
    }
  end

  context 'when a creator has not been registered' do
    it do
      expect { registry.on(key, :found) {} }
        .to raise_error(Zyra::Exceptions::NotRegistered)
    end
  end

  context 'when a creator has been registered' do
    before do
      create(:user, **attributes)
      registry.register(model_class, find_by: :email)
    end

    it 'register a handler to be ran after an event' do
      value = name

      expect { registry.on(key, :found) { |m| m.name = value } }
        .to change { registry.find_or_create(key, attributes).name }
        .from('Some Name').to(name)
    end

    it do
      expect(registry.on(key, :build) {})
        .to be_a(Zyra::FinderCreator)
    end
  end
end
