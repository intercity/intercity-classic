class DigitaloceanStatusWorker
  include Sidekiq::Worker

  def perform(server_id, ssh_key_id)
    server = Server.find(server_id)
    client = DropletKit::Client.new(access_token: server.owner.digitalocean_access_token)
    droplet = client.droplets.find(id: server.digitalocean_id)
    return unless droplet.is_a? DropletKit::Droplet

    if droplet.locked
      DigitaloceanStatusWorker.perform_in(15.seconds, server_id, ssh_key_id)
    else
      server.address = droplet.networks.v4.first.ip_address
      server.username = "root"
      server.save

      default_domain_name(server)

      client.ssh_keys.delete(id: ssh_key_id)
      ServerSshCheckWorker.perform_async(server_id)
    end
  end

  private

  def default_domain_name(server)
    server.applications.update_all(domain_names: server.address)
  end
end
