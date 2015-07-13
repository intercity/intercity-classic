class Onboarding < ActiveRecord::Base
  include RsaKey

  attr_accessor :validation_step

  belongs_to :user
  belongs_to :server
  belongs_to :application

  enum db_type: { postgresql: 0, mysql: 1 }
  enum provider: { custom_server: 0, digitalocean: 1 }
  enum digitalocean_region: { amsterdam: 0, new_york: 1, singapore: 2,
                              london: 3, frankfurt: 4 }

  validates :name, :ruby_version, :db_type,
            presence: true, if: -> { validation_step == :new_app }
  validates :digitalocean_region, :digitalocean_api_key,
            presence: true, if: -> { validation_step == :new_droplet }
  validates :name, format: /\A[A-Za-z0-9_]+\z/, if: proc { |r| r.name.present? }

  def create_server_and_app
    create_server!
    create_app!
    { server: server, app: application }
  end

  private

  def db_type_to_server
    db_type == "postgresql" ? "postgres" : db_type
  end

  def provider_to_server
    provider == "custom_server" ? "metal" : provider
  end

  def create_server!
    server = Server.new(name: "#{name} server", address: ip || "0.0.0.0",
                        username: username,
                        ssh_port: port || "22", working: true, owner: user,
                        stack: "passenger", digitalocean_region: digitalocean_region,
                        provider: provider_to_server, db_type: db_type_to_server)
    server.rsa_key_encrypted = rsa_key_encrypted
    server.save!
    update(server: server)
  end

  def create_app!
    app = Application.create!(server: server, name: name, rails_environment: "production",
                              ruby_version: ruby_version, domain_names: server.address)
    update(application: app)
  end
end
