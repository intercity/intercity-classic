module SslHelper
  def add_ssl_to(app)
    app.update!(enable_ssl: true,
                ssl_cert: File.read("test/fixtures/files/certificate.crt"),
                ssl_key: File.read("test/fixtures/files/certificate.key"))
  end
end
