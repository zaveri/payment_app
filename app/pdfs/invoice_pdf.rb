class InvoicePdf < Prawn::Document
  def initialize(invoice, view)
    super(top_margin: 70)
    @invoice = invoice
    @view = view
    invoice_number
    invoice_items
    total_price
  end
  
  def invoice_number
    text "Order \##{@invoice.invoice_number}", size: 30, style: :bold
  end
  
  def invoice_items
    move_down 20
    table invoice_item_rows do
      row(0).font_style = :bold
      columns(1..3).align = :right
      self.row_colors = ["FFFFFF", "D8E9D7"]
      self.header = true
    end
  end
  
  def invoice_item_rows
    [["Product", "Qty", "Unit Price", "Full Price"]] +
    @invoice.items.map do |item|
      per_item_price = Money.new(item.price, "USD")
      sub_price = Money.new(item.sub_price, "USD")
      [item.description, item.qty,price(per_item_price), price(sub_price)]
    end
  end
  
  def price(num)
    @view.number_to_currency(num)
  end
  
  def total_price
    move_down 15
    totalmoney = Money.new(@invoice.total_due, "USD")
    text "Total Price: #{price(totalmoney)}", size: 16, style: :bold
  end
  
  
end