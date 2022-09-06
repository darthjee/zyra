# frozen_string_literal: true

require 'spec_helper'

describe Zyra do
  describe 'yard' do
    describe '.register' do
      it 'Register models searching' do
        Zyra.register(User, find_by: :email)
        Zyra
          .register(User, :user_by_name, find_by: :name)
          .on(:return) do |user|
            user.update(email: "#{user.name.gsub(/ /, '_')}@srv.com")
          end

        attributes = {
          name: 'my name',
          email: 'my_email@srv.com'
        }

        user = Zyra.find_or_create(:user, attributes)
        expect(user.email).to eq('my_email@srv.com')

        user = Zyra.find_or_create(:user_by_name, attributes)
        expect(user.email).to eq('my_name@srv.com')
      end
    end

    describe '.find_or_create' do
      it 'Regular usage passing all attributes' do
        Zyra.register(User, find_by: :email)

        email = 'email@srv.com'

        user = Zyra.find_or_create(
          :user,
          email: email, name: 'initial name'
        )

        expect(user.name).to eq('initial name')

        user = Zyra.find_or_create(
          :user,
          email: email, name: 'final name'
        )

        expect(user.name).to eq('initial name')
      end
    end

    describe '.on' do
      it 'Adding a hook on return' do
        Zyra.register(User, find_by: :email)
        Zyra.on(:user, :return) do |user|
          user.update(name: 'initial name')
        end

        email = 'email@srv.com'

        user = Zyra.find_or_create(
          :user,
          email: email
        )

        expect(user.name).to eq('initial name')
        user.update(name: 'some other name')

        user = Zyra.find_or_create(:user, email: email)

        expect(user.name).to eq('initial name')
      end

      it 'Adding a hook on found' do
        Zyra.register(User, find_by: :email)
        Zyra.on(:user, :found) do |user|
          user.update(name: 'final name')
        end

        email = 'email@srv.com'
        attributes = { email: email, name: 'initial name' }

        user = Zyra.find_or_create(:user, attributes)

        expect(user.name).to eq('initial name')

        user = Zyra.find_or_create(:user, attributes)

        expect(user.name).to eq('final name')
      end

      it 'Adding a hook on build' do
        Zyra.register(User, find_by: :email)
        Zyra.on(:user, :build) do |user|
          user.name = 'initial name'
        end

        email = 'email@srv.com'

        user = Zyra.find_or_create(:user, email: email)

        expect(user.name).to eq('initial name')
        user.update(name: 'some other name')

        user = Zyra.find_or_create(:user, email: email)

        expect(user.name).to eq('some other name')
      end

      it 'Adding a hook on create' do
        Zyra.register(User, find_by: :email)
        Zyra.on(:user, :create) do |user|
          user.update(name: 'initial name')
        end

        email = 'email@srv.com'

        user = Zyra.find_or_create(:user, email: email)

        expect(user.name).to eq('initial name')
        user.update(name: 'some other name')

        user = Zyra.find_or_create(:user, email: email)

        expect(user.name).to eq('some other name')
      end
    end
  end
end
