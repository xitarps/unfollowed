# The GitHub token is encrypted because job arguments are stored in Redis and logged.
module JobsModules::GithubTokenCipher
  module_function

  def encrypt(token)
    encryptor.encrypt_and_sign(token)
  end

  def decrypt(encrypted_token)
    encryptor.decrypt_and_verify(encrypted_token)
  end

  def encryptor
    key = Rails.application.key_generator.generate_key("github-token-cipher", ActiveSupport::MessageEncryptor.key_len)
    ActiveSupport::MessageEncryptor.new(key)
  end
end
