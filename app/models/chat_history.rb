class ChatHistory < ApplicationRecord
  belongs_to :user
  enum default_models: { 'gpt-3.5-turbo': 0, 'gpt-4': 1  }
  generate_public_uid generator: PublicUid::Generators::HexStringSecureRandom.new(20)

end
