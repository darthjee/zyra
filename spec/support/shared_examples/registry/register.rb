# frozen_string_literal: true

shared_examples 'a method that registers a finder creator' do
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
