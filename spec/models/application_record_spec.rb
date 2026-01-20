require 'rails_helper'

RSpec.describe ApplicationRecord, type: :model do
  describe 'class methods' do
    it 'is an abstract class' do
      expect(described_class.abstract_class).to be true
    end
  end
end
