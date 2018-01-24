FactoryBot.define do
  factory :volume do
    uid
    name
    volume_number { generate(:n) }
  end
end
