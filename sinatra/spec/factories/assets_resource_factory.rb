FactoryBot.define do
  factory :assets_resource do
    created { DateTime.current.strftime('%Y-%m-%d') }
    user_id { generate :name }
    asset_url { generate :name }
    file_size { '10' }
    state { 'awaiting' }
  end
end
