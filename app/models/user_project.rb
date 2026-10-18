class UserProject < ApplicationRecord
  generate_public_uid generator: PublicUid::Generators::HexStringSecureRandom.new(20)
  belongs_to :user
  belongs_to :project
  scope :project_manager_project_ids, -> { where(role: 'project_manager').pluck(:project_id) }
  scope :project_member_project_ids, -> { where(role: 'project_member').pluck(:project_id) }
  enum role: { project_manager: 1, project_member: 2 }
  def to_param
    public_uid
  end
end
