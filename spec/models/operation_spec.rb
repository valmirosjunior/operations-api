require 'rails_helper'

RSpec.describe Operation, type: :model do
  describe 'CURRENCIES constant' do
    it 'contains the expected currencies' do
      expect(Operation::CURRENCIES).to eq(%w[USD BRL])
    end
  end

  describe 'validations' do
    subject { build(:operation) }

    it { is_expected.to validate_presence_of(:external_id) }
    it { is_expected.to validate_uniqueness_of(:external_id) }
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:currency) }
    it { is_expected.to validate_inclusion_of(:currency).in_array(Operation::CURRENCIES) }
  end
end
