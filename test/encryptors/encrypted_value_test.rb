require "test_helper"

class EncryptedValueTest < ActiveSupport::TestCase
  test "It should be able to encrypt data" do
    value_to_encrypt = "sensitive_data"
    encrypted_value = EncryptedValue.dump(value_to_encrypt)
    decrypted_value = EncryptedValue.load(encrypted_value)

    refute_equal encrypted_value, value_to_encrypt
    assert_equal decrypted_value, value_to_encrypt
  end
end
