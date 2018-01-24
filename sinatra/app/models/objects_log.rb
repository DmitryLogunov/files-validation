class ObjectsLog < ActiveRecord::Base
  self.table_name = 'objectsLog'

  alias_attribute :object_date, 'objectDate'
  alias_attribute :db_object_id, 'objectID'
  alias_attribute :object_type, 'objectType'

  enum object_type: { truck: 1, driver: 2, company: 3, trailer: 4 }
end
