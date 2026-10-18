class PromptInputField < ApplicationRecord
  self.inheritance_column = nil
  belongs_to :prompt
  generate_public_uid generator: PublicUid::Generators::HexStringSecureRandom.new(20)

  def to_param
    public_uid
  end

  def options
    prompt.ai_api.ai_api_input_fields.find_by(name: name)&.options
  end
end
