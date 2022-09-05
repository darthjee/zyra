# frozen_string_literal: true

require 'spec_helper'

describe Zyra do
  let(:registry) { described_class }

  before { described_class.reset }

  describe '.register' do
    it_behaves_like 'a method that registers a finder creator'
  end

  describe '.on' do
    it_behaves_like 'a method that registers an event handler'
  end

  describe '.find_or_create' do
    it_behaves_like 'a method that returns or create a model'
  end
end
