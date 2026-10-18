class Company < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :projects, dependent: :destroy
  validates :name, presence: true

  enum company_type: { system_admin: 0, company_service: 1 }
  generate_public_uid generator: PublicUid::Generators::HexStringSecureRandom.new(20)


  def to_param
    public_uid
  end
end
