FactoryBot.define do
  factory :tonnage do
    uid
    name
    tonnage_number { generate :n }
  end
end
