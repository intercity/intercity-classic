require "polarssl"

class EncryptedValue
  cattr_accessor :encryption_key

  def self.dump(obj)
    EncryptedValue.new(obj).dump
  end

  def self.load(encrypted_data)
    EncryptedValue.new(encrypted_data).load
  end

  def initialize(data)
    @data = data
  end

  def dump
    if @data.blank?
      @data = nil # Hmm this seems weird
    end

    initialization_vector = SecureRandom.random_bytes(16)

    cipher = PolarSSL::Cipher.new("AES-128-CTR")
    cipher.setkey(encryption_key, 128, PolarSSL::Cipher::OPERATION_ENCRYPT)
    cipher.set_iv(initialization_vector, 16)

    encoded_object = ActiveSupport::JSON.encode(@data)
    cipher.update(encoded_object)

    encrypted_object = cipher.finish

    encrypted_column = "#{initialization_vector}#{encrypted_object}"

    encrypted_column
  end

  def load
    if @data.blank?
      nil
    else
      initialization_vector = @data[0..15]
      encrypted_object = @data[16..-1]

      cipher = PolarSSL::Cipher.new("AES-128-CTR")
      cipher.setkey(encryption_key, 128, PolarSSL::Cipher::OPERATION_ENCRYPT)
      cipher.set_iv(initialization_vector, 16)
      cipher.update(encrypted_object)
      json = cipher.finish

      ActiveSupport::JSON.decode(json)
    end
  end

  private

  def encryption_key
    hex_to_bin(Settings.intercity.encryption_key)
  end

  def hex_to_bin(hex)
    hex.scan(/../).map { |x| x.hex.chr }.join
  end
end
