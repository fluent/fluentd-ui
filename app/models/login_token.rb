class LoginToken < ActiveRecord::Base
  belongs_to :user

  before_create :generate_unique_id

  scope :active, -> { where("expired_at > ?", Time.zone.now) }
  scope :inactive, -> { where("expired_at <= ?", Time.zone.now) }

  def generate_unique_id
    begin
      token = SecureRandom.base64(32)
    end while self.class.where(token_id: token).exists?
    self.token_id = token
  end
end
