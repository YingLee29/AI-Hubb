class AiApiInputField < ApplicationRecord
  self.inheritance_column = nil
  belongs_to :ai_api
  generate_public_uid generator: PublicUid::Generators::HexStringSecureRandom.new(20)

  def to_param
    public_uid
  end
end
