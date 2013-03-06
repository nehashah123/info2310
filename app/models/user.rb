class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :email, :name, :password
  
  validates :password, presence: true, if: "hashed_password.blank?"
  
  validates :name, presence: true,
                      length: { minimum: 4, maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
                        format: { with: VALID_EMAIL_REGEX },
                      uniqueness: { case_sensitive: false }
  
  has_many :micro_posts

  before_save :encrypt_password
                
  def encrypt_password
    self.salt ||= Digest::SHA256.hexdigest("--#{Time.now.to_s}- -#{email}--")
    self.hashed_password = encrypt(password)
  end

  def encrypt(raw_password)
    Digest::SHA256.hexdigest("--#{salt}--#{raw_password}--")
  end
  
  # If there is a user in the database with the given email, and 
# the password matches theirs, returns the user.
# Otherwise, returns nil
  def self.authenticate(email, plain_text_password)
  	user=User.find_by_email(email)
    if user && user.hashed_password==user.encrypt(plain_text_password)
			return user
		else 
			return nil
		end
  end
  
  def feed(paginate_options={page: 1})
  micro_posts.paginate(paginate_options)
  end
end