class VehicleGroup < ActiveRecord::Base
  self.table_name = 'kkVehicleGroups'

  belongs_to :vehicle_group_type, primary_key: 'uid', foreign_key: 'typeVehicleGroupUID'
  belongs_to :race, primary_key: 'raceUID', foreign_key: 'raceUID'
  belongs_to :tender

  scope :won, -> { where(is_winner: true) }

  alias_attribute :is_winner, 'isWinner'
end
