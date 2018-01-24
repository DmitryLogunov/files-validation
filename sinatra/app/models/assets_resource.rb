#require 'state_machines'

class AssetsResource < ActiveRecord::Base
  enum type_resources: [:driver, :truck, :trailer]

 # state_machine :state, initial: :awaiting do
 #   event :to_process do
 #     transition awaiting: :in_process
 #   end
#    event :to_complete do
#      transition in_process: :complete
#    end
#  end

  scope :all_resources, ->  { where(state: :awaiting).order(created: :desc) }
  scope :drivers, ->  { where(type_resource: :driver).where(state: :awaiting).order(created: :desc) }
  scope :trucks, -> { where(type_resource: :truck).where(state: :awaiting).order(created: :desc) }
  scope :trailers, ->  { where(type_resource: :trailer).where(state: :awaiting).order(created: :desc) }

  def to_process
    self.state = :in_process
    self.save
  end

  def to_complete
    self.state = :complete
    self.save
  end

  def to_complete!
    to_complete
    rescue
  end

  def complete?
    self.state == :complete
  end
end
