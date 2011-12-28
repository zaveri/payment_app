class Invoice
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes
  # invoicee info
  # optional
  field :company, :type => String
  # required
  field :name, :type => String
  field :email, :type => String
  field :stripe_card_token, :type => String
  
  #invoice information
  field :title, :type => String
  field :description, :type => String
  field :invoice_number, :type => String
  
  # date information
  field :invoice_date, :type => Date
  field :due_date, :type => Date
  
  # invoice items/things realtionship
  
  # invoice payment attr using ints
  field :subtotal, :type => Integer
  field :total_due, :type => Integer
  field :tax_total, :type => Integer
  field :tax_rate, :type => Integer
  # other for payments
  field :tax_description, :type => String
  field :payment_received, :type => Boolean, :default => false
  
  
  # other notes/comments
  field :notes_comments, :type => String
  
  # password protect
  field :passphrase, :type => String
  
  
  # realtionships
  has_many :items, :dependent => :destroy , :autosave => true
  accepts_nested_attributes_for :items,  reject_if: proc { |attributes| attributes["description"].blank?}
  belongs_to :user
    
  
  
  # presence name create and update
  validates_presence_of :name, :on => :create
  validates_presence_of :name, :on => :update

  # presence email create and update  
  validates_presence_of :email, :on => :create
  validates_presence_of :email, :on => :update
  
  before_create :generate_phrase, :calc_invoice_backend
  
  protected
  def generate_phrase
    self.passphrase = (0...8).map{65.+(rand(25)).chr}.join
  end
  
  def calc_invoice_backend
    final_total = Money.new(0, "USD")
    self.items.each do |i|
      quantity = i.qty
      price = (i.price.to_f) * 100
      logger.debug "cdfsaf"
      logger.debug price
      i.price = price 
      i.save!
      money = Money.new(i.price, "USD")
      sub_total_item = money * quantity
      logger.debug "fsdaj"
      logger.debug sub_total_item
      logger.debug "fsdaj"
      # store as cents
      i.sub_price = sub_total_item.cents
      i.save!
      # add running totlal for invoice
      final_total = final_total + sub_total_item
    end
    # subtotal without taxes
    self.subtotal = final_total.cents
    # total amount of tax
    temp_tax_total = Money.new(((final_total.cents * self.tax_rate) / 100), "USD")
    self.tax_total = temp_tax_total.cents
    # Total = subtotal = tax_total
    self.total_due = (final_total.cents) +  temp_tax_total.cents
    # save object
  end
  
  
end
