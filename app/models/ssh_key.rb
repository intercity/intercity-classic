class SshKey < ActiveRecord::Base
  belongs_to :server
  validates :server_id, :name, :key, presence: true
end
