FactoryBot.define do
  factory :sql_name do
    name { generate :string }
    kind { rand(2).odd? ? 'Машина' : 'Прицеп' }
  end
end
