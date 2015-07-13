module ApplicationHelper
  def title(title)
    content_for :title do
      title
    end
  end

  def on_applications
    "active" if controller_names.include? %w(dashboard global_applications)
  end

  def on_servers
    "active" if %w(dashboard servers applications ssh_keys env_vars application_databases backups).
                include?(controller_name) && !on_backups
  end

  def on_account
    controller_names = %w(accounts)
    controller_names.include?(controller_name) ? "active" : nil
  end

  def on_backups
    "active" if controller_name == "backups" && action_name == "overview"
  end

  def format_log(log)
    escape_to_html(log).gsub(/\n/, "<br>").gsub(/\ /, "&nbsp;")
  end

  def poll_server_url
    return unless current_server
    if current_app
      poll_server_path(app_id: current_app.id)
    else
      if controller_name == "applications" && action_name == "index"
        poll_server_path(include_deleted: true)
      else
        poll_server_path
      end
    end
  end

  def escape_to_html(data)
    { 1 => :nothing,
      2 => :nothing,
      4 => :nothing,
      5 => :nothing,
      7 => :nothing,
      30 => :black,
      31 => :red,
      32 => :green,
      33 => :yellow,
      34 => :blue,
      35 => :magenta,
      36 => :cyan,
      37 => :white,
      40 => :nothing,
      41 => :nothing,
      43 => :nothing,
      44 => :nothing,
      45 => :nothing,
      46 => :nothing,
      47 => :nothing
    }.each do |key, value|
      if value != :nothing
        data = data.gsub(/\e\[#{key}m/, '<span style="color:#{value}">')
      else
        data = data.gsub(/\e\[#{key}m/, "<span>")
      end
    end
    data = data.gsub(/\e\[0m/, "</span>")
  end
end
