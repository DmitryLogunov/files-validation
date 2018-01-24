class ConditionallyAdmittedDriver < ActiveRecord::Base
  self.table_name = 'conditionallyAdmittedDrivers'
  self.primary_key = 'driverID'

  alias_attribute :driver_id, 'driverID'
  alias_attribute :added_on, 'addedOn'
end
