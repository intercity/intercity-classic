class Application < ActiveRecord::Base
  acts_as_paranoid
  attr_accessor :validate_ssl

  belongs_to :server, touch: true
  belongs_to :connect_to_database_from_application, class_name: "Application"
  has_many :env_vars
  has_one :backup

  validates :name, presence: true, uniqueness: { scope: [:server_id, :deleted_at] }
  validates :name, format: /\A[A-Za-z0-9_]+\z/, if: proc { |r| r.name.present? }
  validate :valid_ssl, if: -> { @validate_ssl == true }
  validates :ssl_cert, :ssl_key, presence: true, if: -> { @validate_ssl == true }

  validates :rails_environment, presence: true
  validates :connect_to_database_from_application_id,
            presence: true,
            if: proc { |r| r.use_database_from_other_application? }
  validates :connect_to_database_from_application_id,
            presence: true,
            inclusion: {
              in: proc { |r| r.server.applications.ids },
              message: "is not available on this server"
            },
            if: proc { |r| r.connect_to_database_from_application_id.present? }

  serialize :database_password_encrypted, EncryptedValue
  serialize :database_user_encrypted, EncryptedValue

  before_create :generate_database_password
  before_create :generate_database_user
  before_create :fill_database_name
  after_create :create_backup_strategy
  after_create :create_default_env_vars

  scope :active_server, -> { joins(:server).includes(:server).where(servers: { archived: false }) }

  RUBY_VERSIONS = ["2.2.2", "2.2.1", "2.1.5", "2.1.3", "2.1.2", "2.0.0-p481", "1.9.3-p547"]

  def formatted_env_vars
    Hash[env_vars.map { |var| [var.key, var.value] }]
  end

  def mark_as_deleting
    update!(deleting: true)
  end

  private

  def generate_database_password
    return unless database_password_encrypted.blank?
    self.database_password_encrypted = SecureRandom.base64
  end

  def generate_database_user
    return unless database_user_encrypted.blank?
    self.database_user_encrypted = SecureRandom.urlsafe_base64[0..15]
  end

  def fill_database_name
    self.database_name = name if database_name.blank?
  end

  def create_backup_strategy
    Backup.create(application: self)
  end

  def create_default_env_vars
    env_vars.create(key: "SECRET_KEY_BASE", value: SecureRandom.hex(64))
  end

  def valid_ssl
    return unless enable_ssl?
    errors.add(:ssl_key, " is invalid") if ssl_key.present? &&
                                           ssl_key.match(/-----BEGIN RSA PRIVATE KEY-----/).nil?

    errors.add(:ssl_cert, " is invalid") if ssl_cert.present? &&
                                            ssl_cert.match(/-----BEGIN CERTIFICATE-----/).nil?
  end
end
