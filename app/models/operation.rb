class Operation < ApplicationRecord
  CURRENCIES = %w[USD BRL].freeze

  validates :external_id, presence: true, uniqueness: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true, inclusion: { in: CURRENCIES }
end
