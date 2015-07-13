class Server < ActiveRecord::Base
  include ServersHelper
  include RsaKey

  DB_TYPES = [:mysql, :postgres].freeze
  enum provider: [:metal, :digitalocean]
  enum digitalocean_region: [:amsterdam, :new_york, :singapore, :london, :frankfurt]

  validates :name, :address, :ssh_port, presence: true

  has_many :applications, dependent: :destroy
  has_many :ssh_keys, dependent: :destroy
  has_one :onboarding
  belongs_to :owner, class_name: "User"

  serialize :mysql_passwords_encrypted, EncryptedValue
  serialize :postgres_passwords_encrypted, EncryptedValue

  after_create :generate_passwords

  scope :archived, -> { where(archived: true) }
  scope :not_archived, -> { where(archived: false) }

  def pending_changes?
    !applied_at || updated_at > applied_at
  end

  def deploy_keys
    if ssh_keys.any?
      ssh_keys.map { |k| k.key }
    else
      []
    end
  end

  def unicorn?
    stack == "rails"
  end

  def passenger?
    stack == "passenger"
  end

  def deploy_users
    (["deploy"] + applications.each.map { |app| app.deploy_user }).uniq
  end

  private

  def generate_passwords
    if mysql_passwords_encrypted.blank?
      self.mysql_passwords_encrypted = {
        server_debian_password: generate_secure_password,
        server_root_password: generate_secure_password,
        server_repl_password: generate_secure_password
      }
    end

    if postgres_passwords_encrypted.blank?
      self.postgres_passwords_encrypted = { password: { postgres: generate_secure_password } }
    end

    save! if changed?
  end
end
