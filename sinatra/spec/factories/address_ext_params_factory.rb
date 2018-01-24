FactoryBot.define do
  factory :address_ext_params do
    kladr { generate :n }

    time_zone 2
  end
end
