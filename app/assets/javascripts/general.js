$(document).ready(function () {
  var currentPage = 1;
  var currentPagePaid = 1;
  var currentPagePending = 1;
  

 $("a.overview_link").click(function (){
   load_invoice_list();
 });
 
 $(".paid_link").click(function (){
   load_paid_list();
 });
 
 $(".pending_link").click(function (){
   load_pending_list();
 });
 
 method_for_total();
 
 $(".qty_field").change(function(){
   stateless_rm_method_for_total();
 });
 
  $(".tax_box").change(function(){
    stateless_rm_method_for_total();
  });
  
  $("#invoice_tax_rate").change(function(){
    stateless_rm_method_for_total();
  });
 
 
  // show more invoices
 $('.more_overview').bind('click', function() {
     loadMore(++currentPage);
  });
  
  $('.more_paid').bind('click', function() {
     loadMorePaid(++currentPagePaid);
  });
  
  $('.more_pending').bind('click', function() {
     loadMorePending(++currentPagePending);
  });
  
  $("#mycredit_form").submit(function(event) {
      // disable the submit button to prevent repeated clicks
      $('#mycredit_form').attr("disabled", "disabled");

      Stripe.createToken({
          number: $('.card-number').val(),
          cvc: $('.card-cvc').val(),
          exp_month: $('.card-expiry-month').val(),
          exp_year: $('.card-expiry-year').val()
      }, stripeResponseHandler);
      
      // prevent the form from submitting with the default action
      return false;
    });
 
});

function remove_fields(link) {
  $(link).closest(".fields").remove();
  // $("#total_price").text(rm_method_for_total(link));
	stateless_rm_method_for_total()
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $("#invoice_items_table tbody").append(content.replace(regexp, new_id));
  method_for_total();
	$(".qty_field").change(function(){
		stateless_rm_method_for_total();
	});
  // for taxes
	$(".tax_box").change(function(){
    stateless_rm_method_for_total();
  });
  // // for tax rate
  // $("#invoice_tax_rate").change(function(){
  //   stateless_rm_method_for_total();
  // });
}

function method_for_total(){
  // console.log("starting");
  // 
  // console.log("inja");
  
  $(".price_field").change(function() {
		var total_value = 0.00;
		var sub_total_final = 0.00;
    all_fields = $(".price_field");
    all_size = all_fields.size()
    
    
    for(i = 0; i < all_size; i++){
			var qty_int = 0;
			var sub_total_value = 0.00;
			sub_total_value_tax = 0.00;
			var sub_price_item = 0.00;
      var float_version;
      if($($('.price_field')[i]).children().val() == ""){
        float_version = 0.00;
      }
      else{
        float_version = parseFloat($($('.price_field')[i]).children().val());
      }

      sub_total_value = sub_total_value + float_version;
      console.log("testing taxes");
      console.log(sub_total_value);

			// get qty for i item
			console.log("cars");
			console.log(qty_int);
			console.log("game");
			qty_int = get_qty_for_price();
			
			
  		if($($(".tax_box")[i]).is(':checked')){

  		  sub_total_value_tax = get_tax_rate(sub_total_value);
        // includes taxes
  		  total_value = total_value + (sub_total_value_tax * qty_int);
  		}
  		else{
  		  total_value = total_value + (sub_total_value * qty_int);  
  		}

      // final sub_total
  		sub_total_final = sub_total_final + (sub_total_value * qty_int);	
			
			sub_price_item = (sub_total_value * qty_int);
			console.log("true");
			console.log(sub_price_item);
			console.log("sub");
			$($(".sub_field")[i]).children().val(sub_price_item.toFixed(2));
			
			
    }
    
    $("#invoice_subtotal").html(sub_total_final.toFixed(2));
    $("#invoice_total_due").html(total_value.toFixed(2));
          
  })
	
}

function get_qty_for_price() {
	var qty_int;
	
	if($($('.qty_field')[i]).children().val() === ""){
		qty_int = 0
	}
	else{
		qty_int = parseInt($($('.qty_field')[i]).children().val());				
	}
	
	return qty_int;
}


function stateless_rm_method_for_total() {
	var total_value = 0.00;
	var sub_total_final = 0.00;
  all_fields = $(".price_field");
  all_size = all_fields.size()
  
  
  for(i = 0; i < all_size; i++){
		var qty_int = 0;
		var sub_total_value = 0.00;
		var sub_total_value_tax = 0.00;
    var float_version;
    var qty_int;
    var sub_price_item = 0.00;
    if($($('.price_field')[i]).children().val() == ""){
      float_version = 0.00;
    }
    else{
      float_version = parseFloat($($('.price_field')[i]).children().val());
      // qty_int = $($('.qty_field')[i]).children().val();
      // console.log(qty_int);
    }

		sub_total_value = sub_total_value + float_version;

		// get qty for i item
		console.log("cars");
		console.log(qty_int);
		console.log("game");
		qty_int = get_qty_for_price();
		
		if($($(".tax_box")[i]).is(':checked')){
		  
		  sub_total_value_tax = get_tax_rate(sub_total_value);
      // includes taxes
		  total_value = total_value + (sub_total_value_tax * qty_int);
		}
		else{
		  total_value = total_value + (sub_total_value * qty_int);  
		}
				
    // final sub_total
		sub_total_final = sub_total_final + (sub_total_value * qty_int);
		
		sub_price_item = (sub_total_value * qty_int);
		console.log("true");
		console.log(sub_price_item);
		console.log("sub");
		$($(".sub_field")[i]).children().val(sub_price_item.toFixed(2));

  }
  
  $("#invoice_subtotal").html(sub_total_final.toFixed(2));
  $("#invoice_total_due").html(total_value.toFixed(2));
}


function get_tax_rate(sub_price_item) {
  var tax_rate = 0.0;
  var all_size;
  var final_value_sub = 0.0;
 if($(".tax_box").is(':checked')){
   tax_rate = parseFloat($("#invoice_tax_rate").val());    
   console.log(tax_rate);
    sub_price_item = sub_price_item + (sub_price_item * (tax_rate/100));
	  console.log("fkdsjaflk");
	  console.log(sub_price_item);
	  final_value_sub = sub_price_item;
	  return final_value_sub;
 }
}

// function rm_method_for_total(link) {
//   rm_price = $($(link).closest(".fields").children()[2]).children().val();
//   if(rm_price === ""){
//     rm_price = 0.00;
//   }
//   rm_float_price = parseFloat(rm_price);
//   // console.log(rm_float_price);
//   rm_total_price = $("#total_price").text();
//   rm_float_total_price = parseFloat(rm_total_price);
//   // console.log(rm_float_total_price);
//   final_price_update = rm_float_total_price -  rm_float_price;
//   return final_price_update;
// }



// function load_invoice_obese_fingers() {
//   $.ajax({
//       url: '/invoices/new',
//       success:function(data){
//         $('#main_pane_invoice').html(data);
//        // remove class from previously selected link
//         $(".pressed_link").removeClass("pressed_link");
//         $("a.new_invoice_link").addClass("pressed_link");
//       }
//     })
// }

function load_invoice_list() {
  $.ajax({
      url: '/invoices',
      success:function(data){
        $('#main_pane_invoice').html(data);
				// remove class from previously selected link
        $(".pressed_link").removeClass("pressed_link");
        $("a.overview_link").addClass("pressed_link");
				$(".super_specific_invoice").click(function (){
				  load_specific_invoice(this);
				});
      }
    })
}

function load_specific_invoice(invoice_item) {
  invoice_id = $(invoice_item).attr("id");
  $.ajax({
      url: '/invoices/' + invoice_id,
      success:function(data){
        $('#main_pane_invoice').hide().html(data).slideDown("slow");
      }
    })
}

function load_paid_list() {
  $.ajax({
      url: '/paidlist',
      success:function(data){
        $('#main_pane_invoice').hide().html(data).slideDown("slow");
				// remove class from previously selected link
        $(".pressed_link").removeClass("pressed_link");
        $("a.paid_link").addClass("pressed_link");
        
				$(".super_specific_invoice").click(function (){
				  load_specific_invoice(this);
				});
				
      }
      
    })
}

function load_pending_list() {
  $.ajax({
    url: '/pendinglist',
    success:function(data){
      $('#main_pane_invoice').hide().html(data).slideDown("slow");
			// remove class from previously selected link
      $(".pressed_link").removeClass("pressed_link");
      $("a.pending_link").addClass("pressed_link");
      
      $(".super_specific_invoice").click(function (){
			  load_specific_invoice(this);
			});  
			
    }
    
  })
}

function loadMore(pageNo) {
  var url = '/moreinvoices?page=';
  $.get(url + pageNo, function(response) {
    if(response === "Fail"){
      $(".more_overview").remove();
      $("#main_pane_invoice").append("<p class='no_more'>No More invoices.</p>");
    }
    else{
      $(".body_invoices").append(response);      
    }
  });
}

function loadMorePaid(pageNo) {
  var url = '/morepaid?page=';
  $.get(url + pageNo, function(response) {
    if(response === "Fail"){
      $(".more_paid").remove();
      $("#main_pane_invoice").append("<p class='no_more'>No More invoices.</p>");
    }
    else{
      $(".body_invoices_paid").append(response);      
    }
  });
}

function loadMorePending(pageNo) {
  var url = '/morepending?page=';
  $.get(url + pageNo, function(response) {
    if(response === "Fail"){
      $(".more_pending").remove();
      $("#main_pane_invoice").append("<p class='no_more'>No More invoices.</p>");
    }
    else{
      $(".body_invoices_pending").append(response);      
    }
  });
}

function stripeResponseHandler(status, response) {  
  if (response.error) {
      // re-enable the submit button
      $('.submit_button').removeAttr("disabled");
      // show the errors on the form
      $("#error_explanation").html(response.error.message);
  } else {
      // var form$ = $("#credit-form");
      // token contains id, last4, and card type
      // var token = response['id'];
      // insert the token into the form so it gets submitted to the server
      $('#invoice_stripe_card_token').val(response.id);
      console.log(response);
      $('#mycredit_form')[0].submit();
  }
}


