class SqlName < ActiveRecord::Base
  scope :trailers, -> { where(kind: 'Прицеп') }
  scope :trucks, -> { where(kind: 'Машина') }
end
