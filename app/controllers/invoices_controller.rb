require "prawn"
require "prawn/core"

class InvoicesController < ApplicationController
  
  before_filter :logged_in?, :except => [:show, :charge_credit_invoice]
  
  def index 
    if(!params[:sort])
      attribute = 'email'
    else
      attribute = params[:sort]
    end
    
    if(!params[:direction])
      direction = 'asc'
    else
      direction = params[:direction]
    end
    
    logger.debug attribute
    @invoices = Invoice.all(sort: [[ attribute, direction]]).page(params[:page]).per(5)
  end
  
  def new
    @invoice = Invoice.new
    @invoice.items.build
    # render :layout => false
  end
  
  def create
    @invoice = Invoice.new(params[:invoice])
    # foreign key
    @invoice.user_id = current_user.id
    if(@invoice.save)
      redirect_to root_path
    else
      render :new
    end
  end
  
  def edit
    @invoice = Invoice.find(params[:id])
  end
  
  def update
    @invoice = Invoice.find(params[:id])
    # Stripe.api_key = ""
    # total_invoice_stripe = Money.new(@invoice.total_due, "USD")
    # charge = Stripe::Charge.create(:amount => total_invoice_stripe.cents, :currency => "usd", :card => params[:invoice][:stripe_card_token], :description => @invoice.invoice_number)
    # @invoice.stripe_card_token = charge.id
    # if(@invoice.save!)
    #   @invoice.payment_received = true
    #   @invoice.save!
    #   redirect_to invoice_path(@invoice.id)
    # else
    #   redirect_to root_path
    # end
  end
  
  # method to process cc for x invoice
  def charge_credit_invoice
    @invoice = Invoice.find(params[:id])
    Stripe.api_key = ""
    total_invoice_stripe = Money.new(@invoice.total_due, "USD")
    
    charge = Stripe::Charge.create(
      :amount => total_invoice_stripe.cents,
      :currency => "usd",
      :card => params[:invoice][:stripe_card_token],
      :description => @invoice.invoice_number
    )
        
    @invoice.stripe_card_token = charge.id
    if(@invoice.save!)
      @invoice.payment_received = true
      @invoice.save!
      redirect_to invoice_path(@invoice.id)
    else
      redirect_to root_path
    end
  end
  
  def show
    @invoice = Invoice.find(params[:id])
    new_money = Money.new(@invoice.total_due, "USD")
    respond_to do |format|
      format.html
      format.pdf do
        pdf = InvoicePdf.new(@invoice, view_context)
        send_data pdf.render, filename: "invoice_#{@invoice.invoice_number}.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end
  
  def invoicelist
    @invoices = Invoice.find(:all)
    render :layout => false
  end
  
  def paid
    # query via mongoid for unpaid invoices
    @paid_invoices = Invoice.where(payment_received: true).page(params[:page]).per(5)
  end
  
  def pending
    # query via mongoid for unpaid invoices
    @pending_invoices = Invoice.where(payment_received: false).page(params[:page]).per(2)
  end
  
  # get more invoices pagination
  
  def more_invoices
    # logic to see how many possbile pages there are...
    total_invoices = Invoice.find(:all).length
    logger.debug total_invoices
    pages_possible = total_invoices / 5.0
    dec = pages_possible.abs.modulo(1) 
    if(dec > 0.0)
      pages_possible = pages_possible.to_i + 1
    end
    
    # if less than 5 invoices for x user do not try and load.
    if(total_invoices <= 5)
      render :text => "Fail"
    else
      @invoices = Invoice.page(params[:page]).per(5)
      current_page = params[:page].to_i
      total_page = @invoices.length
      if(current_page > pages_possible)
        render :text => "Fail"
      else
        render :layout => false      
      end
    end
    
  end
  
  def more_paid
    
    # logic to see how many possbile pages there are...
    total_paid_invoices = Invoice.where(payment_received: true).length
    logger.debug total_paid_invoices
    pages_possible = total_paid_invoices / 5.0
    dec = pages_possible.abs.modulo(1) 
    if(dec > 0.0)
      pages_possible = pages_possible.to_i + 1
    end
    
    # if less than 5 invoices for x user do not try and load.
    if(total_paid_invoices <= 5)
      render :text => "Fail"
    else
      @paid_invoices = Invoice.where(payment_received: true).page(params[:page]).per(5)
      current_page = params[:page].to_i
      total_page = @paid_invoices.length
      if(current_page > pages_possible)
        render :text => "Fail"
      else
        render :layout => false      
      end
    end
        
  end
  
  def more_pending
    
    # logic to see how many possbile pages there are...
    total_pending_invoices = Invoice.where(payment_received:false).length
    logger.debug total_pending_invoices
    pages_possible = total_pending_invoices / 2.0
    dec = pages_possible.abs.modulo(1) 
    if(dec > 0.0)
      pages_possible = pages_possible.to_i + 1
    end
    
    # if less than 5 invoices for x user do not try and load.
    if(total_pending_invoices <= 2)
      render :text => "Fail"
    else
      @pending_invoices = Invoice.where(payment_received: false).page(params[:page]).per(2)
      current_page = params[:page].to_i
      total_page = @pending_invoices.length
      if(current_page > pages_possible)
        render :text => "Fail"
      else
        render :layout => false      
      end
    end
    
  end
  
  
  # toggle methods if payments were or were not made
  def payment_made
    invoice = Invoice.find(params[:id])
    invoice.payment_received = true
    invoice.save!
    redirect_to root_path    
  end
  
  # if u marked it paid by mistake
  def payment_revert
    invoice = Invoice.find(params[:id])
    invoice.payment_received = false
    invoice.save!
    redirect_to root_path
  end
  
end





