class OperationInteractor
  def initialize(external_id:, amount:, currency:)
    @external_id = external_id
    @amount = amount
    @currency = currency
  end

  def execute
    Operation.find_or_create_by!(external_id: @external_id) do |operation|
      operation.amount = @amount
      operation.currency = @currency
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique, PG::UniqueViolation => error
    Operation.find_by(external_id: @external_id) || raise(error)
  end
end
