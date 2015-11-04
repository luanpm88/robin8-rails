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


#  $('body').on 'click', '.iCheck-helper', (e) ->
#    checked = $(this).closest("div").hasClass("checked")
#    check_all = $(this).closest("div").find(".check_all").length > 0
#    if check_all
#      if checked
#        $(this).closest(".section").find('input[type="checkbox"]').iCheck('check');
#      else
#        $(this).closest(".section").find('input[type="checkbox"]').iCheck('uncheck');
#        $(this).closest(".section").find('input[type="number"]').val()

# 关闭某项
#  $("body").on "change", ".row input[type='checkbox']", (e) ->
#    checked = $(this).closest("div").hasClass("checked")
#    if !checked
#      $(this).closest(".row").find("input[type='number']").val()

# 输入某项 ，自动check
#  $("body").on "blur", ".row input[type='number']", (e) ->
#    console.log("blur");
#    val = $(this).val()
#    if val
#      $(this).closest(".row").find("input[type='checkbox']").closest("div").addClass("checked")
#


