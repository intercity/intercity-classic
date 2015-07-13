class BackupFetchService
  def initialize(applications, s3_connection = nil)
    @applications = Array(applications)
    @result = {}
    @s3_connection = s3_connection
  end

  def execute
    @applications.each do |app|
      @result[app.name] = fetch_backups(app)
    end
    @result
  end

  private

  def fetch_backups(app)
    connection = s3_connection(app)
    items = []
    if connection
      connection.sync_clock
      bucket = connection.directories.get(app.backup.s3_bucket, prefix: "intercitybackups/#{app.name}/")
      if bucket
        files = bucket.files.sort_by(&:last_modified).reverse.first 5
        files.each do |file|
          items << { name: format_key(file.key),
                     url: bucket.files.get_http_url(file.key, 10.minutes.from_now) }
        end
      end
    end

    if items.count == 0
      items << { error: "There are no backups for this app yet." }
    end
    items
  rescue Excon::Errors::Forbidden, TypeError
    items << { error: "Could not connect to your AWS account" }
  end

  def format_key(key)
    to_format = key.split("/").last(2)
    "#{to_format.last} - #{I18n.l Date.parse(to_format.first)}"
  end

  def s3_connection(app)
    Fog::Storage.new(
      aws_access_key_id: app.backup.s3_access_key.to_s,
      aws_secret_access_key: app.backup.s3_secret_access_key.to_s,
      provider: "AWS",
      region: app.backup.s3_region
    )
  end
end
