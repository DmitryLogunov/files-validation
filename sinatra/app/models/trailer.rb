require File.expand_path("../../", __FILE__) + '/models/conserns/loading_types'

class Trailer < ActiveRecord::Base
  include LoadingTypes

  self.primary_key = 'trailerID'

  belongs_to :company, foreign_key: 'userID'

  scope :active, -> { where("(trailers.deleted IS NULL OR trailers.deleted = 0)") }

  alias_attribute :trailer_id, 'trailerID'
  alias_attribute :user_id, 'userID'
  alias_attribute :name, 'trailerName'
  alias_attribute :full_number, 'trailerFullNumber'
  alias_attribute :vin, 'VIN'
  alias_attribute :chassis_number, 'chassisNumber'
  alias_attribute :added_on, 'addedOn'
  alias_attribute :type, 'trailerType'
  alias_attribute :days_block, 'numDaysResoursesBlock'
  alias_attribute :kk_race_days_block, 'kkRaceNumDaysResourcesBlock'
  alias_attribute :vehicle_group_uid, 'vehicleGroupUID'
  alias_attribute :back_loading, 'backLoading'
  alias_attribute :side_loading, 'sideLoading'
  alias_attribute :top_loading, 'topLoading'

  def self.joins_last_black_numbers_and_black_vins
    joins('LEFT JOIN blackTrailerNumbers ON ' \
          'trailers.trailerFullNumber = blackTrailerNumbers.trailerFullNumber AND ' \
          'blackTrailerNumbers.stated = (SELECT MAX(blackTrailerNumbers.stated) FROM blackTrailerNumbers ' \
           'WHERE blackTrailerNumbers.trailerFullNumber = trailers.trailerFullNumber)')
    .joins('LEFT JOIN blackTrailerVINs ON ' \
           'trailers.VIN = blackTrailerVINs.vin AND blackTrailerVINs.stated =  ' \
           '(SELECT MAX(blackTrailerVINs.stated) FROM blackTrailerVINs ' \
           'WHERE blackTrailerVINs.vin = trailers.VIN)')
  end

  def self.in_black_list
    joins_last_black_numbers_and_black_vins
      .where('blackTrailerNumbers.blackState = true OR blackTrailerVINs.blackState = true')
  end

  def to_s
    "#{name} #{full_number}"
  end

  def to_formatted_s
    #TODO: Добавить форматирование кода региона в скобки
    "#{name}, #{full_number}"
  end

  def full_number_characters
    return "" if full_number.blank?
    full_number.split[0]
  end

  def full_number_digits
    return "" if full_number.blank?
    full_number.split[1]
  end

  def full_number_region
    return "" if full_number.blank?
    full_number.split[2]
  end

  def black_numbers
    Trailer::BlackNumber.where(full_number: full_number)
  end

  def black_vins
    Trailer::BlackVin.where(vin: vin)
  end

  # Файлы пркрепляемые в парсерной части
  def old_attachments
    ResourceOldAttachment.where('trailerID = ? OR truckFullNumber = ?', id, full_number)
  end

  def admission_date
    @admission_date ||= begin
      return unless days_block

      max_date = Trailer.joins_last_black_numbers_and_black_vins
        .where('trailers.trailerID = ?', self.id)
        .where('(blackTrailerNumbers.blackState = false OR blackTrailerNumbers.blackState IS NULL) OR ' \
                '(blackTrailerVINs.blackState = false OR blackTrailerVINs.blackState IS NULL)')
        .pluck('Date(blackTrailerNumbers.stated)', 'Date(blackTrailerVINs.stated)', 'trailers.addedOn')
        .flatten.compact.max

      return unless max_date
      return unless (Date.current - max_date).to_i < days_block

      max_date + days_block
    end
  end
end
