# frozen_string_literal: true

require 'spec_helper'

describe Zyra::Registry do
  let(:registry) { described_class.new }

  describe 'yard' do
    describe '#registry' do
      it 'Regular usage' do
        registry.register(User, find_by: :email)

        email = 'email@srv.com'

        model = registry.find_or_create(
          :user,
          email: email, name: 'initial name'
        )

        expect(model.name).to eq('initial name')

        model = registry.find_or_create(
          :user,
          email: email, name: 'final name'
        )

        expect(model.name).to eq('initial name')
      end
    end
  end
end
