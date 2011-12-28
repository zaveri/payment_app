pdf.move_down 70

# Add the font style and size
pdf.font "Helvetica"
pdf.font_size 18
pdf.text_box "Invoice # #{@invoice.invoice_number}", :align => :right

pdf.font_size 22
pdf.text "Thank you for your order, #{@invoice.name}.", :align => :center
pdf.move_down 20

pdf.font_size 14
pdf.text "Below you can find your order details. We hope you shop with Awesome Company again in the future. Now unleash those fonts like hell have no fury!", :align=> :center

pdf.text "Invoice ##{@invoice.id}", :size => 30, :style => :bold

pdf.move_down(30)

items = @invoice.items.map do |item|
  [
    item.description,
    item.qty,
    number_to_currency(item.sub_price),
    number_to_currency(item.price)
  ]
end

pdf.table items, :border_style => :underline_header,
  :row_colors => ["FFFFFF","DDDDDD"],
  :headers => ["Product", "Qty", "Unit Price", "Full Price"],
  :align => { 0 => :left, 1 => :right, 2 => :right, 3 => :right }

pdf.move_down(10)

pdf.text "Total Price: #{number_to_currency(@invoice.total_due)}", :size => 16, :style => :bold