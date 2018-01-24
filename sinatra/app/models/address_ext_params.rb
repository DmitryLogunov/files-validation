class AddressExtParams < ActiveRecord::Base
  self.table_name = 'kkExtParamsAddress'

  belongs_to :address, primary_key: 'addressID', foreign_key: 'addressID'

  alias_attribute :kladr, 'KLADR'
  alias_attribute :address_id, 'addressID'
end
