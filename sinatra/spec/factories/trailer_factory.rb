FactoryBot.define do
  factory :trailer do
    trailer_id { generate :n }
    user_id { create(:company).id }
    added_on { 1.day.ago }

    name { generate :name }
    full_number { generate :name }
    vin { generate :name }
    vehicle_group_uid { generate :uid }
    deleted false

    after(:create) do |trailer|
      unless VehicleGroupType.exists?(uid: trailer.vehicle_group_uid)
        create :vehicle_group_type, uid: trailer.vehicle_group_uid
      end
    end
  end
end
