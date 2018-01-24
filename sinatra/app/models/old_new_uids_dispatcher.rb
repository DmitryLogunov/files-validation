class OldNewUidsDispatcher < ActiveRecord::Base
  self.table_name = 'oldNewUIDsDispatchers'

  alias_attribute :new_uid, 'newUID'
  alias_attribute :old_uid, 'oldUID'
end
