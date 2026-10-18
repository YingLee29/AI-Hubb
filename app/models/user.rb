class User < ApplicationRecord
  acts_as_tenant(:company)
  VALID_EMAIL_REGEX = /\A([\w+\-]\.?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  has_many :user_projects, dependent: :destroy
  has_many :prompts, dependent: :destroy
  has_many :projects, through: :user_projects
  belongs_to :company
  has_many :chat_histories, dependent: :destroy
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable
  before_save :strip_spaces

  validates :name,  length: { maximum: 100}, presence: true, format: { without: %r{[/?%#,;:"\\]} }
  validates :email, format: { with: VALID_EMAIL_REGEX},
                    uniqueness: true,
                    length: { maximum: 100},
                    presence: true
  validates :phone, format: { with: /\A\d+\z/, message: "Please enter only integers" }, length: { is: 10 },  if: :phone_exist?
  generate_public_uid generator: PublicUid::Generators::HexStringSecureRandom.new(20)

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { admin: 1, member: 2 }
  enum gender: { male: 1, female: 2, not_applicable: 3 }

  validates_format_of :password, without: /\s/
  validates_format_of :password, without: /\p{Katakana}|\p{Hiragana}|\p{Han}/

  def to_param
    public_uid
  end

  def phone_exist?
    !phone.blank?
  end

  def target_chat_history(prompt)
    current_user_chat = chat_histories.where(prompt_id: prompt.id) if prompt.present?
    target_chat_id = if current_user_chat.present?
                    current_user_chat.first&.public_uid
                  else
                    new_chat = ChatHistory.create!(user_id: id, prompt_id: prompt.id)
                    new_chat&.public_uid
                  end
    current_chat = ChatHistory.find_by(public_uid: target_chat_id)
    user_history_chat = chat_histories.where(prompt_id: prompt.id)
    user_chat_content = current_chat&.metadata
    response_ai = user_chat_content&.map { |item| item['bot_response'] }
    return current_chat, user_history_chat, user_chat_content, response_ai
  end

  private

  def strip_spaces
    attributes = %w[name]
    attributes.each { |attribute| self[attribute] = self[attribute].strip if self[attribute] }
  end
end
