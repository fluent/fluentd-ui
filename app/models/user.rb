class User < ActiveRecord::Base
  has_secure_password

  validates :name, uniqueness: true, presence: true
  validates :remember_token, uniqueness: true, allow_nil: true

  def generate_remember_token
    begin
      token = SecureRandom.base64(32)
    end while User.where(remember_token: token).exists?
    token
  end
end
