# frozen_string_literal: true

require 'spec_helper'

describe Zyra::Finder do
  subject(:finder) { described_class.new(model_class, keys) }

  let(:model_class) { User }
  let(:keys)        { :email }
  let(:email)       { SecureRandom.hex(10) }

  describe '#find' do
    let(:attributes) do
      {
        name: 'Some Name',
        email: email,
        password: 'SomePassword'
      }
    end

    context 'when there is no entry in the database' do
      it do
        expect(finder.find(attributes)).to be_nil
      end
    end

    context 'when the entry is there with the same attributes' do
      let!(:user) { create(:user, **attributes) }

      it 'returns the user' do
        expect(finder.find(attributes)).to eq(user)
      end
    end

    context 'when the entry is there with other attributes' do
      let!(:user) { create(:user, email: email) }

      it 'returns the user' do
        expect(finder.find(attributes)).to eq(user)
      end
    end

    context 'when there is another entry' do
      before { create(:user) }

      it 'returns the user' do
        expect(finder.find(attributes)).to be_nil
      end
    end

    context 'when the keys is set as string' do
      let(:keys)  { 'email' }
      let!(:user) { create(:user, **attributes) }

      it 'finds the user the same way' do
        expect(finder.find(attributes)).to eq(user)
      end
    end

    context 'when the attributes have string keys' do
      let(:attributes) { { 'email' => email } }
      let!(:user)      { create(:user, **attributes) }

      it 'finds the user the same way' do
        expect(finder.find(attributes)).to eq(user)
      end
    end
  end
end
