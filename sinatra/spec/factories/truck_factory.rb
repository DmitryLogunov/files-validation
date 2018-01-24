FactoryBot.define do
  factory :truck do
    truck_id { generate :n }
    user_id { create(:company).email }
    added_on { 1.day.ago }

    name { generate :name }
    full_number { generate :name }
    vin { generate :string }
    deleted false

    check_state true
    allow_state true

    phone { generate :russian_phone }
    vehicle_group_uid { generate :uid }

    after(:create) do |truck, _evaluator|
      ObjectsLog.create! objectID: truck.truck_id,
                         objectType: 1,
                         objectDate: DateTime.current,
                         action: 'unlockTruck',
                         author: FactoryBot.generate(:name)
    end
  end
end
