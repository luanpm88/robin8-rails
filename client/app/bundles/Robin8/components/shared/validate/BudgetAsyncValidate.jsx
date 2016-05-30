export default function BudgetAsyncValidate(value){
  if ($(".budget-input").attr("brand-amount")) {

    let brand_amount = parseInt($(".budget-input").attr("brand-amount"));

    if($(".budget-input").attr("data-is-edit") && $(".budget-input").attr("data-origin-budget") ){
      brand_amount += parseInt($(".budget-input").attr("data-origin-budget"));
    }

    if(parseInt(value) > brand_amount){
      $(".budget-show-error").show();
    } else {
      $(".budget-show-error").hide();
    }
  }

  fetch('/brand_api/v1/user', { credentials: 'same-origin' })
    .then(function(response){
      response.json().then(function(data){
        $(".budget-input").attr("brand-amount", parseInt(data.avail_amount))
      })
    })
}
