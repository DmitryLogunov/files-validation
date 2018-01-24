class VehicleGroupType < ActiveRecord::Base
  self.table_name = 'kkTypeVehicleGroup'

  USED_TRAILER_TYPE_NAMES = %w[Рефрижератор Тент Изотермический Фургон Бортовой].freeze

  validates :uid, presence: true, uniqueness: true

  belongs_to :tonnage, primary_key: 'uid', foreign_key: 'tonnageUID'
  belongs_to :volume, primary_key: 'uid', foreign_key: 'volumeUID'
  belongs_to :body_type, primary_key: 'uid', foreign_key: 'trailerTypeUID'

  has_many :races, through: :vehicle_groups
  has_many :packets, through: :packet_vehicle_groups

  alias_attribute :vehicle_group_type_name, 'vehicleGroupTypeName'
  alias_attribute :name, 'vehicleGroupTypeName'
  alias_attribute :trailer_type_uid, 'trailerTypeUID'
  alias_attribute :trailer_type_name, 'trailerTypeName'
  alias_attribute :tonnage_uid, 'tonnageUID'
  alias_attribute :volume_uid, 'volumeUID'
  alias_attribute :marked_delete, 'markedDelete'
  alias_attribute :marked, 'markedDelete'

  scope :main, -> { where(trailer_type_name: USED_TRAILER_TYPE_NAMES) }
  scope :filter, ->(trailer_type, tonnage, volume) {  joins(:volume)
                                                        .joins(:tonnage)
                                                        .where(trailer_type_name: trailer_type,
                                                               kkTonnage: { tonnageNumber: tonnage },
                                                               kkVolume:  { volumeNumber: volume }) }

  def to_s
    "#{name}, #{uid}"
  end

  def self.get_uid(trailer_type, tonnage, volume)
    self.filter(trailer_type, tonnage, volume).pluck(:uid).first
  end

  def self.is_exists?(trailer_type, tonnage, volume)
    self.filter(trailer_type, tonnage, volume).exists?
  end

  def self.get_type_and_size_by_uid(uid)
    self.joins(:volume)
      .joins(:tonnage)
      .where(uid: uid)
      .limit(1)
      .pluck('kkTypeVehicleGroup.trailerTypeName, kkTonnage.tonnageNumber, kkVolume.volumeNumber')
      .first
  end
end
