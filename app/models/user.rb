class User < ActiveRecord::Base
  has_secure_password

  def generate_remember_token
    begin
      token = SecureRandom.base64(32)
    end while User.where(remember_token: token).exists?
    token
  end
end
