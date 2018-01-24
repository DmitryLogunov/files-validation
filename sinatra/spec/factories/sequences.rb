FactoryBot.define do
  sequence(:n) { |n| n }
  sequence(:float) { |n| n / 100.0 }
  sequence(:big_float) { rand(100) + ((1 + rand(9)) / 100.0) }
  sequence(:uid) { SecureRandom.uuid }
  sequence(:date_time) { |n| n.hours.ago }
  sequence(:date) { |n| Date.new 2000 + n }
  sequence(:time) { Time.new }
  sequence(:email) { |n| "user-#{n}@host.com" }
  sequence(:name) { |n| "name-#{n}" }
  sequence(:string) { |n| "string-#{n}" }
  sequence(:short_string) { |n| "s-#{n}" }
  sequence(:phone) { |n| "+7#{'%010d' % (n % 10**10)}" }
  sequence(:phone_ext) { |n| '%004d' % (n % 10**4) }
  sequence(:russian_phone) { |n| "8#{'%010d' % (n % 10**10)}" }
  sequence(:phone_for_truck_form) { |n| "+7(#{'%003d' % (n % 10**3)})#{'%003d' % (n % 10**3)}-#{'%002d' % (n % 10**2)}-#{'%002d' % (n % 10**2)}" }
  sequence(:bool, &:odd?)
  sequence(:cladr) { |n| "5500700000600000000000000" }  #TODO: correct generation
end
