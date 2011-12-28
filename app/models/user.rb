class User
  include ActiveModel::SecurePassword
  include Mongoid::Document
  has_secure_password
  
  # auth info
  field :email, :type => String
  field :password_digest, :type => String
  # user info
  field :name, :type => String
  
  # stripe info
  
  field :stripekey, :type => String
  field :privatekey, :type => String
  
  field :user_id, :type => String
  
  
  # for Stripe/plans
  
  # their subscription id from us recurring
  
  # field :stripeid, type => String
  # field :active, :type => Boolean, default: falses
  # field :plan, :type => String
  # field :coupon, :type => String
  
  
  
  # realtionships
  has_many :invoices
  
  
  validates_presence_of :password, :on => :create
  validates_presence_of :email, :on => :create
  validates_presence_of :email, :on => :update
  
  validates_uniqueness_of :email, :on => :create
  validates_uniqueness_of :email, :on => :update
end
