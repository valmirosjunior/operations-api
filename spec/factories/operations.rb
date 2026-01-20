FactoryBot.define do
  factory :operation do
    external_id { Faker::Alphanumeric.alphanumeric(number: 10) }
    amount { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    currency { Operation::CURRENCIES.sample }
  end
end
