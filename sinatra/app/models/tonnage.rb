class Tonnage < ActiveRecord::Base
  self.table_name = 'kkTonnage'

  validates :uid, presence: true, uniqueness: true

  has_many :vehicle_group_types, primary_key: 'uid', foreign_key: 'tonnageUID'

  alias_attribute :tonnage_number, 'tonnageNumber'
  alias_attribute :trailer_required_tonnage, 'trailerRequiredTonnage'
  alias_attribute :tender_dlt, 'tenderDLT'
  alias_attribute :marked_delete, 'markedDelete'
  alias_attribute :marked, 'markedDelete'
end
