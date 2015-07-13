module ServersHelper
  def active_on(url, exact_match: true)
    if exact_match
      return "active" if request.path == url
    else
      return "active" if "#{request.path}/".include?("#{url}/")
    end
  end

  # Constructs options array for the form builder:
  # [["MySQL", :mysql], ["PostgreSQL", :postgres]]
  def db_type_options(db_types = Server::DB_TYPES)
    db_types.map { |type| [t(type, scope: "server.db_type_options"), type] }
  end

  def generate_secure_password
    SecureRandom.base64
  end

  def chef_repo_path
    Settings.chef_repo.path
  end
end
