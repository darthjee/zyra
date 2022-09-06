# frozen_string_literal: true

require 'spec_helper'

describe Zyra::Registry do
  describe 'yard' do
    describe '#register' do
      it 'Register models searching' do
        registry = Zyra::Registry.new

        registry.register(User, find_by: :email)
        registry
          .register(User, :user_by_name, find_by: :name)
          .on(:return) do |user|
            user.update(email: "#{user.name.gsub(/ /, '_')}@srv.com")
          end

        attributes = {
          name: 'my name',
          email: 'my_email@srv.com'
        }

        user = registry.find_or_create(:user, attributes)
        expect(user.email).to eq('my_email@srv.com')

        user = registry.find_or_create(:user_by_name, attributes)
        expect(user.email).to eq('my_name@srv.com')
      end
    end

    describe '#find_or_create' do
      it 'Regular usage passing all attributes' do
        registry = Zyra::Registry.new
        registry.register(User, find_by: :email)

        email = 'email@srv.com'

        user = registry.find_or_create(
          :user,
          email: email, name: 'initial name'
        )

        expect(user.name).to eq('initial name')

        user = registry.find_or_create(
          :user,
          email: email, name: 'final name'
        )

        expect(user.name).to eq('initial name')
      end
    end

    describe '#on' do
      it 'Adding a hook on return' do
        registry = Zyra::Registry.new
        registry.register(User, find_by: :email)
        registry.on(:user, :return) do |user|
          user.update(name: 'initial name')
        end

        email = 'email@srv.com'

        user = registry.find_or_create(
          :user,
          email: email
        )

        expect(user.name).to eq('initial name')
        user.update(name: 'some other name')

        user = registry.find_or_create(:user, email: email)

        expect(user.name).to eq('initial name')
      end

      it 'Adding a hook on found' do
        registry = Zyra::Registry.new
        registry.register(User, find_by: :email)
        registry.on(:user, :found) do |user|
          user.update(name: 'final name')
        end

        email = 'email@srv.com'
        attributes = { email: email, name: 'initial name' }

        user = registry.find_or_create(:user, attributes)

        expect(user.name).to eq('initial name')

        user = registry.find_or_create(:user, attributes)

        expect(user.name).to eq('final name')
      end

      it 'Adding a hook on build' do
        registry = Zyra::Registry.new
        registry.register(User, find_by: :email)
        registry.on(:user, :build) do |user|
          user.name = 'initial name'
        end

        email = 'email@srv.com'

        user = registry.find_or_create(:user, email: email)

        expect(user.name).to eq('initial name')
        user.update(name: 'some other name')

        user = registry.find_or_create(:user, email: email)

        expect(user.name).to eq('some other name')
      end

      it 'Adding a hook on create' do
        registry = Zyra::Registry.new
        registry.register(User, find_by: :email)
        registry.on(:user, :create) do |user|
          user.update(name: 'initial name')
        end

        email = 'email@srv.com'

        user = registry.find_or_create(:user, email: email)

        expect(user.name).to eq('initial name')
        user.update(name: 'some other name')

        user = registry.find_or_create(:user, email: email)

        expect(user.name).to eq('some other name')
      end
    end
  end
end
