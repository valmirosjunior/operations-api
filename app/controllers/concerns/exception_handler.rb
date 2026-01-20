module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :render_internal_server_error
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
    rescue_from ActiveRecord::RecordNotUnique, with: :render_unprocessable_entity
    rescue_from PG::UniqueViolation, with: :render_unprocessable_entity
    rescue_from ActionController::ParameterMissing, with: :render_bad_request
    rescue_from ArgumentError, with: :render_bad_request
  end

  private

  def render_unprocessable_entity(exception)
    errors = if exception.respond_to?(:record) && exception.record.respond_to?(:errors)
      exception.record.errors.full_messages
    else
      [ exception.message ]
    end

    render json: { errors: errors }, status: :unprocessable_entity
  end

  def render_bad_request(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def render_internal_server_error(exception)
    Rails.logger.error "#{exception.class}: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")

    message = Rails.env.production? ? "Internal Server Error" : exception.message

    render json: { error: message }, status: :internal_server_error
  end
end
