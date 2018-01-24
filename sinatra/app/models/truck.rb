require File.expand_path("../../", __FILE__) + '/models/conserns/loading_types'

class Truck < ActiveRecord::Base
  include LoadingTypes

  self.primary_key = 'truckID'

    belongs_to :company, foreign_key: 'userID'

  scope :active, -> { where("(trucks.deleted IS NULL OR trucks.deleted = 0)") }
  scope :admitted, -> { where(check_state: true, allow_state: true) }
  scope :not_admitted, -> do
    where('trucks.checkState IS NULL OR trucks.checkState = false OR ' \
          'trucks.allowState IS NULL OR trucks.allowState = false')
  end

  alias_attribute :truck_id, 'truckID'
  alias_attribute :user_id, 'userID'
  alias_attribute :name, 'truckName'
  alias_attribute :full_number, 'truckFullNumber'
  alias_attribute :vin, 'VIN'
  alias_attribute :added_on, 'addedOn'
  alias_attribute :check_state, 'checkState'
  alias_attribute :allow_state, 'allowState'
  alias_attribute :engine_number, 'engineNumber'
  alias_attribute :body_number, 'bodyNumber'
  alias_attribute :chassis_number, 'chassisNumber'
  alias_attribute :vrc_owner, 'VRCowner'
  alias_attribute :vrc_number, 'VRCnumber'
  alias_attribute :new_data, 'newData'
  # TODO: переименовать :days_block -> :ltl_days_block
  alias_attribute :days_block, 'numDaysResoursesBlock'
  alias_attribute :ftl_days_block, 'kkRaceNumDaysResourcesBlock'
  alias_attribute :must_have_trailer, 'mustHaveTrailer'
  alias_attribute :vehicle_group_uid, 'vehicleGroupUID'
  alias_attribute :top_loading, 'topLoading'
  alias_attribute :side_loading, 'sideLoading'
  alias_attribute :back_loading, 'backLoading'

  def self.joins_last_black_numbers_and_black_vins
    joins('LEFT JOIN blackNumbers ON trucks.truckFullNumber = blackNumbers.truckFullNumber AND ' \
           'blackNumbers.stated = (SELECT MAX(blackNumbers.stated) FROM blackNumbers ' \
           'WHERE blackNumbers.truckFullNumber = trucks.truckFullNumber)')
    .joins('LEFT JOIN blackVINs ON trucks.VIN = blackVINs.vin AND blackVINs.stated =  ' \
           '(SELECT MAX(blackVINs.stated) FROM blackVINs WHERE blackVINs.vin = trucks.VIN)')
  end

  def self.in_black_list
    joins_last_black_numbers_and_black_vins
      .where('blackNumbers.blackState = true OR blackVINs.blackState = true')
  end

  def to_s
    "#{name} #{full_number}"
  end

  def to_formatted_s
    #TODO: Добавить форматирование кода региона в скобки
    "#{name}, #{full_number}"
  end

  def full_number_first_characters
    return "" if full_number.blank?
    full_number.split[0]
  end

  def full_number_digits
    return "" if full_number.blank?
    full_number.split[1]
  end

  def full_number_second_characters
    return "" if full_number.blank?
    full_number.split[2]
  end

  def full_number_region
    return "" if full_number.blank?
    full_number.split[3]
  end

  def black_numbers
    Truck::BlackNumber.where(full_number: full_number)
  end

  def black_vins
    Truck::BlackVin.where(vin: vin)
  end

  def admitted?
    check_state && allow_state
  end

  # Файлы пркрепляемые в парсерной части
  def old_attachments
    ResourceOldAttachment.where('truckID = ? OR truckFullNumber = ?', id, full_number)
  end
end
