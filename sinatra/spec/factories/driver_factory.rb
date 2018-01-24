FactoryBot.define do
  factory :driver do
    name
    address { generate :string }
    license_number { generate :string }
    passport_series '01'
    passport_number '111'
    added_on { 1.day.ago }
    user_id { generate :email }
    check_state true
    allow_state true

    address_id { create(:address).id }

    after(:create) do |driver, _evaluator|
      ObjectsLog.create! objectID: driver.driver_id,
                         objectType: 2,
                         objectDate: DateTime.current,
                         action: 'unlockDriver',
                         author: FactoryBot.generate(:name)
      DriverProxy.create! driverID: driver.driver_id, copy: true
    end
  end
end
