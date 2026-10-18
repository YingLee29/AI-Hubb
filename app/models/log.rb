class Log < ApplicationRecord
  belongs_to :prompt
  belongs_to :project

  scope :by_project_id, ->(project_id) { where(project_id:) }
end
