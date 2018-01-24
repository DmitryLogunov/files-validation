FactoryBot.define do
  factory :objects_log do
    object_date { DateTime.current }
    action { 'lockTruck' }
    author { create(:admin_user).full_name }
    db_object_id { create(:truck).id }
    object_type { 'truck' }
  end
end
