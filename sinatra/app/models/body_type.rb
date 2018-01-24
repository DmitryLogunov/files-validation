class BodyType < ActiveRecord::Base
  self.table_name = 'kkTypeTrailers'

  validates :uid, presence: true, uniqueness: true

  has_many :vehicle_group_types, foreign_key: 'trailerTypeUID', primary_key: 'uid'

  alias_attribute :marked_delete, 'markedDelete'
  alias_attribute :marked, 'markedDelete'

  def self.all_types
    self.distinct.pluck(:name)
  end
end
