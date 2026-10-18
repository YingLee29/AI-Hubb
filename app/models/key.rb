class Key < ApplicationRecord
  belongs_to :prompt, optional: true
  belongs_to :user
  generate_public_uid generator: PublicUid::Generators::HexStringSecureRandom.new(20)

  validates :key_string, presence: true, uniqueness: true
  validates :prompt, presence: { message: 'Prompt is not found!' }

  def to_param
    public_uid
  end

  def self.generate_key
    SecureRandom.hex(64)
  end

  def status
    return 'Active' if valid_until.nil? || valid_until > Time.now()

    'Deactive'
  end
end
