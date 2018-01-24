class Company < ActiveRecord::Base
  BAD_RATING_THRESHOLD = 4
  CATEGORY_FULL_ACCESS_TENDERS = 4

  self.table_name = 'registry'
  self.primary_key = 'email'

  belongs_to :manager, class_name: 'Worker', foreign_key: 'managerID'

  has_one :dispatcher_category, foreign_key: 'userID'
  has_one :white_listed_dispatcher, foreign_key: 'dispatcherID'
  has_many :tender_additional_agreements
  has_many :auto_tender_offers, primary_key: 'email', foreign_key: 'userID'
  belongs_to :old_new_uids_dispatcher, primary_key: 'oldUID', foreign_key: 'dispatcherUID'
  has_many :companies_polls, foreign_key: :company_email, inverse_of: :company
  has_many :polls, through: :companies_polls
  has_many :dispatcher_subs, primary_key: :dispatcherUID, foreign_key: :dispatcherUID
  has_many :subscribes, through: :dispatcher_subs

  #FIXME: почти одинаковые скоупы
  scope :active, -> { where("registry.blocked != 1 OR registry.blocked IS NULL").where.not(approved: nil) }
  scope :consonant_to_new_poll_email_notification, -> { joins(dispatcher_subs: :subscribe).where(dispatcherSubs: { state: DispatcherSub::ACTIVE_STATE }, subscribes: { sendBy: Subscribe::SEND_BY_EMAIL, type: Subscribe::TYPE_POLL }) }
  scope :consonant_to_chain_races_email_notification, -> { joins(dispatcher_subs: :subscribe).where(dispatcherSubs: { state: DispatcherSub::ACTIVE_STATE }, subscribes: { sendBy: Subscribe::SEND_BY_EMAIL, type: Subscribe::TYPE_CHAIN }) }
  scope :non_blocked, -> { where(blocked: nil).where.not(approved: nil, dispatcher_uid: nil) }

  alias_attribute :type, 'companyType'
  alias_attribute :name, 'companyName'
  alias_attribute :address, 'companyAddress'
  alias_attribute :postal_address, 'companyPostalAddress'
  alias_attribute :owner_type, 'ownerType'
  alias_attribute :phone_first, 'phone1'
  alias_attribute :phone_second, 'phone2'
  alias_attribute :orgn, 'OGRN'
  alias_attribute :okved, 'OKVED'
  alias_attribute :authorized_person, 'authorizedPerson'
  alias_attribute :authorized_person_status, 'authorizedPersonStatus'
  alias_attribute :authorization_reason, 'authorizationReason'
  alias_attribute :self_park, 'selfPark'
  alias_attribute :attract_park, 'attractPark'
  alias_attribute :more_info, 'moreInfo'
  alias_attribute :auth_status_id, 'dispatcherAuthStatusID'
  alias_attribute :total_insurance, 'totalInsurance'
  alias_attribute :dispatcher_uid, 'dispatcherUID'
  alias_attribute :contract_id, 'contractID'
  alias_attribute :bank_name, 'bankName'
  alias_attribute :ogrn_date, 'OGRNdat'
  alias_attribute :warranty_num, 'warrantyNum'
  alias_attribute :warranty_date, 'warrantyDat'
  alias_attribute :sms_phone, 'SMScellphone'
  alias_attribute :subscribe_email, 'subscribeEmail'
  alias_attribute :cities_insurance, 'citiesInsurance'
  alias_attribute :req_work, 'reqWork'
  alias_attribute :manager_id, 'managerID'
  alias_attribute :address_id, 'addressID'
  alias_attribute :postal_address_id, 'postalAddressID'
  alias_attribute :inn, 'INN'
  alias_attribute :kpp, 'KPP'
  alias_attribute :ogrn, 'OGRN'
  alias_attribute :bik, 'BIK'
  alias_attribute :receive_notifications_about_polls, 'receiveNotificationsAboutPolls'

  def phones
    [phone_first, phone_second].select(&:present?)
  end

  def mailing_address
    subscribe_email.presence || email
  end

  def full_name
    "#{type} \"#{name}\""
  end

  def with_first_category?
    dispatcher_category.try(:category) == 1
  end

  def without_category?
    dispatcher_category.try(:category).in? [nil, 0]
  end

  def nds
    self[:nds] == 1
  end

  def nds?
    nds
  end

  def with_nds?
    warn "`with_nds?` is deprecated, use `nds` or `nds?`"
    nds
  end

  def bad_rating?
    rating.to_f < BAD_RATING_THRESHOLD
  end

  def good_rating?
    !bad_rating?
  end

  def full_access_tender?
    category_rating_access == CATEGORY_FULL_ACCESS_TENDERS
  end

  def self_employed?
    type == 'ИП'
  end
end
