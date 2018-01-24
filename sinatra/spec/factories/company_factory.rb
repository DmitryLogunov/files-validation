FactoryBot.define do
  factory :company do
    email { generate :email }
    type { 'OOO' }
    name { generate :name }
    address { generate :string }
    postal_address { generate :string }
    owner_type { 'owner' }
    phone_first { generate :phone }
    person { generate :name }
    authorized_person { generate :name }
    authorized_person_status { 'Директор' }
    authorization_reason { 'устав' }
    orgn { generate :n }
    contract_expiry_date { 1.week.since }
    okved { generate :n }
    nds { generate :bool }
    dispatcher_uid { generate :string }
    approved { 1.year.ago }
    rating { generate :n }
    address_id nil
    postal_address_id nil
    kk_contract_date { generate(:date) }

    after :build do |company|
      OldNewUidsDispatcher.create! new_uid: FactoryBot.generate(:uid),
                                   old_uid: company.dispatcher_uid
    end

    factory :first_category_company do
      after(:create) do |c|
        DispatcherCategory.create! company: c, category: 1
      end
    end

    factory :zero_category_company do
      after(:create) do |c|
        DispatcherCategory.create! company: c, category: 0
      end
    end
  end
end
