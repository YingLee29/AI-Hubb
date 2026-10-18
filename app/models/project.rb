class Project < ApplicationRecord
  acts_as_tenant(:company)

  encrypts :public_uid, deterministic: true
  encrypts :description
  encrypts :application_domain, deterministic: true

  has_many :prompts, dependent: :destroy
  has_many :logs, dependent: :destroy
  has_many :user_projects, dependent: :destroy
  has_many :users, through: :user_projects
  belongs_to :company
  generate_public_uid generator: PublicUid::Generators::HexStringSecureRandom.new(20)

  validates :application_domain, presence: { message: ->(object, data) { "Application Domain can't be blank " } },
    length: { maximum: 255, message: ->(object, data) { "Application Domain is too long (maximum is 255 characters)" } }

  def to_param
    public_uid
  end
end
