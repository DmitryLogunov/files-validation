FactoryBot.define do
  factory :vehicle_group_type do
    uid { generate :uid }
    trailer_type_name { %w[Рефрижератор Тент Изотермический Фургон].sample }
    name { generate :string }
    body_type
    tonnage
    volume

    after(:create) do |vehicle_group_type|
      unless BodyType.exists?(uid: vehicle_group_type.trailer_type_uid)
        create :body_type, uid: vehicle_group_type.trailer_type_uid
      end
    end
  end
end
