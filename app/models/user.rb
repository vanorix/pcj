class User < ActiveRecord::Base
  has_many :course_students
  has_many :courses, through: :course_students
  has_many :assignment_ownerships, class_name: :Assignment, foreign_key: 'owner_id'
  has_many :course_ownerships, class_name: :Course, foreign_key: 'owner_id'
  has_many :problem_ownerships, class_name: :Problem, foreign_key: 'owner_id'
  has_many :problem_solutions, class_name: StudentPortal::ProblemSolution
  has_many :user_connections
  has_many :connections, through: :user_connections

  attr_accessor :remember_token, :activation_token
  before_save { email.downcase! }
  before_save   :downcase_email
  before_create :create_activation_digest
  before_create :create_connection_token
  before_create :toggle_professor #DO THIS WITH ROLE AND USER_ROLE MODEL INSTEAD


  validates :name, presence: true, length: { maximum: 50 }
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
                    length: { maximum: 255 },
                    format: { with: EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  validate :validate_email_domain

  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  validates :connection_token, uniqueness: true

  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def name_with_email
    "#{name}(#{email})"
  end

  def remember
    self.remember_token = User.new_token
    update_attributes(remember_digest: User.digest(remember_token))
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def activate
    update_attributes(activated: true, activated_at: Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def connect(connection_id)
    User.transaction do
      begin
        connection = User.find(connection_id)
        raise ActiveRecord::RecordNotUnique, "can't connect with self"  if connection.eql?(self)

        connections << connection
        connection.connections << self

        save!
        connection.save!
      rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordNotFound
        return false;
      end
    end
    true
  end

  private  def downcase_email
    self.email = email.downcase
  end

  private def toggle_professor
    local, domain = email.split('@')
    self.professor = true if (/^\d{8}$/ =~ local).nil?
  end

  private def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

  private def create_connection_token
    self.connection_token = User.new_token
  end

  private def valid_domains
    %w(ce.pucmm.edu.do)
  end

  private def validate_email_domain
    local, domain = email.split('@')
    errors.add(:email, :invalid, message: 'this domain is not part of the accepted list') unless valid_domains.include?(domain)
  end
end
