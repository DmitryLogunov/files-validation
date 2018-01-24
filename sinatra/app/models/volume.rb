class Volume < ActiveRecord::Base
  self.table_name = 'kkVolume'

  validates :uid, presence: true, uniqueness: true

  has_many :vehicle_group_types, primary_key: 'uid', foreign_key: 'volumeUID'

  alias_attribute :volume_number, 'volumeNumber'
  alias_attribute :trailer_required_volume, 'trailerRequiredVolume'
  alias_attribute :tender_dlt, 'tenderDLT'
  alias_attribute :marked_delete, 'markedDelete'
  alias_attribute :marked, 'markedDelete'
end
