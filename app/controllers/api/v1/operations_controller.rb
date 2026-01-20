class Api::V1::OperationsController < ApplicationController
  def create
    operation = ::OperationInteractor.new(
      external_id: operation_params[:external_id],
      amount: operation_params[:amount],
      currency: operation_params[:currency]
    ).execute

    render json: operation, status: :created
  end

  private

  def operation_params
    params.permit(:external_id, :amount, :currency)
  end
end
