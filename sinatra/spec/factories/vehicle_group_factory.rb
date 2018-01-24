FactoryBot.define do
  factory :vehicle_group do
    raceUID { generate :n }
    vehicle_group_type
    is_winner true
    tender_id nil
  end
end
