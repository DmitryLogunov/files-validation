class Driver < ActiveRecord::Base
  self.primary_key = 'driverID'

  scope :active, -> { where("(drivers.deleted IS NULL OR drivers.deleted = 0)") }
  scope :admitted, -> { where(checkState: 1, allowState: 1) }

  alias_attribute :driver_id, 'driverID'
  alias_attribute :added_on, 'addedOn'
  alias_attribute :license_number, 'licenseNumber'
  alias_attribute :license_given_by, 'licenseGivenBy'
  alias_attribute :license_given_date, 'licenseGivenDate'
  alias_attribute :passport_type, 'passportType'
  alias_attribute :passport_series, 'passportSeries'
  alias_attribute :passport_number, 'passportNumber'
  alias_attribute :passport_given_by, 'passportGivenBy'
  alias_attribute :passport_given_date, 'passportGivenDate'
  alias_attribute :user_id, 'userID'
  alias_attribute :check_state, 'checkState'
  alias_attribute :allow_state, 'allowState'
  alias_attribute :birth_date, 'birthDate'
  alias_attribute :address_id, 'addressID'
  alias_attribute :phone_1, 'phone1'
  alias_attribute :phone_2, 'phone2'
  alias_attribute :phone_3, 'phone3'

  def to_s
    "#{name} #{passport_series} #{passport_number}"
  end
end
