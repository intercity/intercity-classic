class ServerLog
  def initialize(server)
    @server = server
  end

  def move_old
    return unless File.exist?(file)
    FileUtils.mv(file, "#{Rails.root}/log/servers/#{@server.id}-#{Time.now.to_i}-previous.log", force: true)
  end

  def file
    if test_mode?
      "/dev/null"
    else
      FileUtils.mkdir_p("log/servers") unless File.directory?("log/servers")
      Rails.root.join("log", "servers", "#{@server.id}.log")
    end
  end

  def logger
    Logger.new(file)
  end

  def latest(n = 100)
    command = %W(tail -#{n} #{file})
    log = ""
    IO.popen(command) do |io|
      log = io.read
    end
    log
  end

  private

  def test_mode?
    Rails.env.test?
  end
end
