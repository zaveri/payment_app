class Item
  include Mongoid::Document
  
  field :description, :type => String
  field :qty, :type => Integer
  field :price, :type => Integer
  field :sub_price, :type => Integer
  
  belongs_to :invoice
  
end
