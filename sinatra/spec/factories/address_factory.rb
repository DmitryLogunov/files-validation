FactoryBot.define do
  factory :address do
    city { generate :name }
    street { generate :name }
    house { '42' }
    building { 'a' }
    apartment { '13' }
    address_ext_params
  end
end
