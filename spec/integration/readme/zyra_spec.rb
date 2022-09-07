# frozen_string_literal: true

require 'spec_helper'

describe Zyra do
  describe 'readme' do
    it 'registering a model' do
      Zyra
        .register(User, find_by: :email)
        .on(:build) do |user|
          user.reference = SecureRandom.hex(16)
        end

      attributes = {
        email: 'usr@srv.com',
        name: 'Some User',
        password: 'pass'
      }

      user = Zyra.find_or_create(:user, attributes) do |usr|
        usr.update(attributes)
      end

      expect(user.name).to eq('Some User')
      expect(user.email).to eq('usr@srv.com')
      expect(user.password).to eq('pass')
      expect(user.reference).not_to be_nil
    end
  end
end
