module RsaKey
  extend ActiveSupport::Concern
  included do
    serialize :rsa_key_encrypted, EncryptedValue
  end

  def generate_rsa_key!
    return unless rsa_key_encrypted.blank?

    key = OpenSSL::PKey::RSA.new(1024)
    public_key = key.public_key

    self.rsa_key_encrypted = { "private" => key.to_pem,
                               "public" => public_key.to_pem }
    save!
  end
end
