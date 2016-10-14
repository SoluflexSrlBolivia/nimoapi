class User < ActiveRecord::Base
	has_one :folder, :as=> :folderable
  has_many :user_groups
	has_many :groups, through: :user_groups
  has_many :aliases, :as=> :aliasable
  has_many :devices
  has_many :notifications
  has_many :posts
  has_many :comments
  
  validates_length_of :aliases, maximum: 5
  
  attr_accessor :remember_token, :activation_token, :reset_token, :name
  before_save   :downcase_email
  before_create :create_activation_digest
  before_create :generate_authentication_token
  after_create :create_root_folder

  #validates :name,  presence: true, length: { maximum: 50 }
  validates :name,  length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\-.]+\.[a-z]+\z/i
  VALID_PASSWORD_REGEX = /\A(?=\.*?[A-Z])/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX, message: I18n.t('error_email_format') },
                    uniqueness: { case_sensitive: false, message: I18n.t('error_email_already_exist') }
  has_secure_password
  validates :password, length: { minimum: 8 }, allow_blank: true,
            format: { with: VALID_PASSWORD_REGEX, message: I18n.t('error_password_format') }

  validates :password_confirmation, :presence => true, :if => '!password.nil?'

  include PgSearch
  pg_search_scope :search, :against => [:firstname, :lastname, :email, :gender, :occupation],
  :using => {
            :tsearch => {:prefix => true},
            :trigram => {:only => [:firstname, :lastname, :email, :gender, :occupation]}
          },
  ignoring: :accents

  #change status deleted to true
  def delete_user
    begin
      self.deleted = true
      self.save!
    rescue => e
      puts "error:delete_user:#{e}"
      return false
    end

    true
  end

  #full name
  def name
    "#{self.firstname} #{self.lastname}".strip
  end

  def notifier_name
    if "#{self.firstname} #{self.lastname}".strip.size > 0
      return "#{self.firstname} #{self.lastname}".strip
    elsif !alias_selected.nil?
      return alias_selected.name
    end

    self.email
  end

  #Create the root folder
  def create_root_folder
    root_folder = Folder.new(:name=>".", :owner_type=>"User", :owner_id=>self.id)
    self.folder = root_folder
    self.save!
  end

  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Activates an account.
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  private

    # Converts email to all lower-case.
    def downcase_email
      self.email = email.downcase
    end

    # Creates and assigns the activation token and digest.
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

    def generate_authentication_token
      loop do
        self.authentication_token = SecureRandom.base64(64)
        break unless User.find_by(authentication_token: authentication_token)
      end
    end
end
