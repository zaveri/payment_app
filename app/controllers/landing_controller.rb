class LandingController < ApplicationController
  
  def index
    @invoices = Invoice.find(:all)
  end
  
end
