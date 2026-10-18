class AiApi < ApplicationRecord
  has_many :ai_api_input_fields, dependent: :destroy
  has_many :prompts, dependent: :destroy
  accepts_nested_attributes_for :ai_api_input_fields
  enum ai_type: { completion: 0, chat_completion: 1, edit: 2, image_generation: 3, image_edit: 4 }, _suffix: true
  generate_public_uid generator: PublicUid::Generators::HexStringSecureRandom.new(20)

  scope :api_available, -> { where(ai_type: ['completion', 'chat_completion']) }

  def to_param
    public_uid
  end
end
