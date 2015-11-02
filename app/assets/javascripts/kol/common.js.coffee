$(document).ready ->
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


