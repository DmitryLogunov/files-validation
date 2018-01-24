class Address < ActiveRecord::Base
  self.table_name = 'address'
  self.primary_key = 'addressID'

  has_one :address_ext_params, primary_key: 'addressID', foreign_key: 'addressID'
  has_many :routes, primary_key: 'addressID', foreign_key: 'addressID'

  alias_attribute :address_id, 'addressID'
  alias_attribute :city, 'adCity'
  alias_attribute :street, 'adStreet'
  alias_attribute :house, 'adHouse'
  alias_attribute :building, 'adBuilding'
  alias_attribute :apartment, 'adApartment'

  after_initialize :init_blanks

  def init_blanks
    self['adIndex'] ||= ''
    self['adRegion'] ||= ''
    self['adZone'] ||= ''
    self['adTown'] ||= ''
    self['adRegionCode'] ||= ''
    self['adZoneCode'] ||= ''
    self['adCityCode'] ||= ''
    self['adTownCode'] ||= ''
    self['adStreetCode'] ||= ''
  end

  def full_address
    formatted_building =
      if building? && building != '-'
        "(#{building})"
      else
        ''
      end
    formatted_house =
      if house?
        "дом №#{house}#{formatted_building}"
      end
    formatted_apartment =
      if apartment? && apartment != '-'
        "кв./офис #{apartment}"
      else
        ''
      end

    [city, street, formatted_house, formatted_apartment].select(&:present?).join(', ')
  end
end
