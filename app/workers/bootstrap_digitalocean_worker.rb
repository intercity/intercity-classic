class BootstrapDigitaloceanWorker
  include Sidekiq::Worker

  def perform(server_id)
    @server = Server.find(server_id)
    ssh_key = create_ssh_key

    droplet = DropletKit::Droplet.new(name: @server.name.dasherize.parameterize,
                                      region: find_free_subregion,
                                      image: "ubuntu-14-04-x64",
                                      size: default_server_size,
                                      ssh_keys: [ssh_key.id])
    created_droplet = client.droplets.create(droplet)
    @server.update(digitalocean_id: created_droplet.id)
    DigitaloceanStatusWorker.perform_async(server_id, ssh_key.id)
  rescue DropletKit::FailedCreate => e
    @server.update(bootstrapped: false, working: false,
                   last_error: "We could not create a server. \n" \
                               "DigitalOcean gave us the following reason: #{e}")
  rescue => e
    @server.update(bootstrapped: false, working: false,
                   last_error: e.message)
  end

  private

  def client
    @client ||= DropletKit::Client.new(access_token: @server.owner.digitalocean_access_token)
  end

  def find_free_subregion
    regions = client.regions.all
    handle_error_from_digitalocean_response(regions) if regions.is_a? String
    regions.each do |region|
      if /#{mapped_region}/.match(region.slug) && region.available
        return region.slug if region.sizes.include?(default_server_size)
      end
    end
    raise "No free region was found."
  end

  def mapped_region
    case @server.digitalocean_region
    when "amsterdam"
      "ams"
    when "new_york"
      "nyc"
    when "london"
      "lon"
    when "frankfurt"
      "fra"
    when "singapore"
      "sg"
    end
  end

  def create_ssh_key
    @server.generate_rsa_key!
    ssh_key = SSHKey.new(@server.rsa_key_encrypted["private"], comment: "intercity")
    key = DropletKit::SSHKey.new(public_key: ssh_key.ssh_public_key,
                                 name: Digest::MD5.hexdigest("Intercity - #{@server.name}"))

    if key_exists?(ssh_key.md5_fingerprint)
      client.ssh_keys.delete(id: ssh_key.md5_fingerprint)
    end

    key = client.ssh_keys.create(key)

    handle_error_from_digitalocean_response(key) if key.is_a? String

    key
  end

  def key_exists?(fingerprint)
    key = client.ssh_keys.find(id: fingerprint)
    key.is_a? DropletKit::SSHKey
  end

  def default_server_size
    "1gb"
  end

  def handle_error_from_digitalocean_response(response)
    error_message = JSON.parse(response).try(:fetch, "message")
    raise BootstrappingError, error_message
  end

  class BootstrappingError < StandardError
  end
end
