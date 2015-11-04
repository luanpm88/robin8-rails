$(document).ready ->
#  收缩、展开
  $("body").on "click", ".toggle-button", (e) ->
    state = $(this).hasClass("glyphicon-plus")
    if state
      $(this).closest(".toggle-box").find(".toggle-list").show()
      $(this).addClass("glyphicon-minus")
      $(this).removeClass("glyphicon-plus")
    else
      $(this).closest(".toggle-box").find(".toggle-list").hide()
      $(this).removeClass("glyphicon-minus")
      $(this).addClass("glyphicon-plus")

  $('body').on 'change', '.check_all', (e) ->
    checked = $(this).is(':checked')
    console.log checked
    if checked
      $(this).closest(".section").find('input[type="checkbox"]').attr("value",1);
    else
      $(this).closest(".section").find('input[type="checkbox"]').attr("value",0);
      $(this).closest(".section").find('input[type="number"]').val('')
    $(this).closest(".section").find('input[type="checkbox"]').checkboxX('refresh')

# 关闭某项 输入
  $("body").on "change", ".row .price-item", (e) ->
    console.log "row checkbox"
    checked = $(this).is(':checked')
    if !checked
      $(this).closest(".row").find("input[type='number']").val('')

# 输入某项价格 ，自动check
  $("body").on "blur", ".row input[type='number']", (e) ->
    val = $(this).val()
    if val
      $(this).closest(".row").find("input[type='checkbox']").attr("value",1)
      $(this).closest(".row").find("input[type='checkbox']").checkboxX('refresh')


