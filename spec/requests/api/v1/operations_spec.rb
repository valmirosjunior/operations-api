require 'rails_helper'

RSpec.describe 'API::V1::Operations', type: :request do
  describe 'POST /api/v1/operations' do
    let(:external_id) { 'ext_123' }
    let(:amount) { 100.50 }
    let(:currency) { 'USD' }
    let(:params) { { external_id: external_id, amount: amount, currency: currency } }

    context 'when operation does not exist' do
      it 'creates a new operation' do
        expect {
          post '/api/v1/operations', params: params, as: :json
        }.to change(Operation, :count).by(1)
      end

      it 'returns created status' do
        post '/api/v1/operations', params: params, as: :json

        expect(response).to have_http_status(:created)
      end

      it 'returns the operation data' do
        post '/api/v1/operations', params: params, as: :json

        json = JSON.parse(response.body)
        expect(json['external_id']).to eq(external_id)
        expect(json['amount']).to eq(amount.to_s)
        expect(json['currency']).to eq(currency)
      end
    end

    context 'when operation already exists' do
      let!(:existing_operation) { create(:operation, external_id: external_id) }

      it 'does not create a new operation' do
        expect {
          post '/api/v1/operations', params: params, as: :json
        }.not_to change(Operation, :count)
      end

      it 'returns created status' do
        post '/api/v1/operations', params: params, as: :json

        expect(response).to have_http_status(:created)
      end

      it 'returns the same operation data' do
        post '/api/v1/operations', params: params, as: :json

        json = JSON.parse(response.body)
        expect(json['id']).to eq(existing_operation.id)
        expect(json['external_id']).to eq(external_id)
      end
    end

    context 'when operation is invalid' do
      let(:invalid_params) { { external_id: nil, amount: -10, currency: 'INVALID' } }

      it 'does not create an operation' do
        expect {
          post '/api/v1/operations', params: invalid_params, as: :json
        }.not_to change(Operation, :count)
      end

      it 'returns unprocessable entity status' do
        post '/api/v1/operations', params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'returns error messages' do
        post '/api/v1/operations', params: invalid_params, as: :json

        json = JSON.parse(response.body)
        expect(json['errors']).to be_present
      end
    end

    context 'when an unexpected error occurs' do
      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(::OperationInteractor).to receive(:execute).and_raise(StandardError.new('Unexpected error'))
        # rubocop:enable RSpec/AnyInstance
      end

      it 'returns internal server error status' do
        post '/api/v1/operations', params: params, as: :json

        expect(response).to have_http_status(:internal_server_error)
      end

      it 'returns error message in test environment' do
        post '/api/v1/operations', params: params, as: :json

        json = JSON.parse(response.body)
        expect(json['error']).to eq('Unexpected error')
      end
    end
  end
end
