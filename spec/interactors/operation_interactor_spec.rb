require 'rails_helper'

RSpec.describe OperationInteractor do
  describe '#execute' do
    subject(:interactor) { described_class.new(external_id: external_id, amount: amount, currency: currency) }

    let(:external_id) { 'ext_123' }
    let(:amount) { 100.50 }
    let(:currency) { 'USD' }

    context 'when operation does not exist' do
      it 'creates a new operation' do
        expect {
          interactor.execute
        }.to change(Operation, :count).by(1)
      end

      it 'returns the created operation' do
        operation = interactor.execute

        expect(operation).to be_a(Operation)
        expect(operation.external_id).to eq(external_id)
        expect(operation.amount).to eq(amount)
        expect(operation.currency).to eq(currency)
      end
    end

    context 'when operation already exists' do
      let!(:existing_operation) { create(:operation, external_id: external_id) }

      it 'does not create a new operation' do
        expect {
          interactor.execute
        }.not_to change(Operation, :count)
      end

      it 'returns the existing operation' do
        expect(interactor.execute).to eq(existing_operation)
      end
    end

    context 'when operation is invalid' do
      let(:external_id) { nil }
      let(:amount) { -10 }
      let(:currency) { 'INVALID' }

      it 'raises an error' do
        expect {
          interactor.execute
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when processing concurrently' do
      it 'prevents duplicate operations' do
        threads = []
        operations = []

        5.times do
          threads << Thread.new do
            operations << described_class.new(external_id: external_id, amount: amount, currency: currency).execute
          end
        end

        threads.each(&:join)

        expect(Operation.where(external_id: external_id).count).to eq(1)
      end
    end
  end
end
