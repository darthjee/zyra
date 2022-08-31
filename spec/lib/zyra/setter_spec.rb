# frozen_string_literal: true

require 'spec_helper'

describe Zyra::Setter do
  subject(:setter) { described_class.new(model) }

  let(:model)     { User.new }
  let(:attribute) { model.attributes.keys.sample.to_sym }
  let(:value)     { SecureRandom.hex(10) }

  context 'when model responds to a setter method' do
    it 'sets the value in the model' do
      expect { setter.public_send(attribute, value) }
        .to change(model, attribute)
        .from(nil).to(value)
    end
  end

  context 'when model does not responds to a setter method' do
    let(:attribute) { :some_random_attribute }

    it do
      expect { setter.public_send(attribute, value) }
        .to raise_error(NoMethodError)
    end
  end

  context 'when model responds to a setter method with wrong argumens' do
    it do
      expect { setter.public_send(attribute) }
        .to raise_error(ArgumentError)
    end
  end
end
