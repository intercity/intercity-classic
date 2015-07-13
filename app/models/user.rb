class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :onboardings, dependent: :destroy
  has_many :servers, foreign_key: :owner_id, dependent: :destroy
  has_many :applications, through: :servers

  def flipper_id
    "User::#{id}"
  end

  validates :full_name, presence: true, on: :create

  def name
    full_name
  end

  def avatar_url(size = 24)
    hash = Digest::MD5.hexdigest(email)
    "https://www.gravatar.com/avatar/#{hash}?s=#{size}"
  end

  def applications_with_backups
    Application.includes("backup").where(server_id: servers.not_archived).
      where(backups: { enabled: true })
  end
end
