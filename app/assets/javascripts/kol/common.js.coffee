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

  # 注意  如果需要选中 先设置未选中 然后调用trigger('change') 这样可以触发回调函数
  $('body').on 'change', '.check_all', (e) ->
    checked = $(this).is(':checked')
    console.log checked
    if checked
      $(this).closest(".section").find('input.price-item[type="checkbox"]').attr("value",0);
    else
      $(this).closest(".section").find('input.price-item[type="checkbox"]').attr("value",1);
      $(this).closest(".section").find('input[type="text"]').val('')
#      $(this).closest(".section").find("i").css("display","none")
    $(this).closest(".section").find('input[type="checkbox"]').checkboxX('refresh')
    $(this).closest(".section").find("input.price-item[type='checkbox']").trigger('change')

# 关闭某项 输入
  $("body").on "change", ".row .price-item", (e) ->
    checked = $(this).is(':checked')
    if !checked
      $(this).closest(".row").find("input[type='text']").val('')
#      #校验的符号 也要去掉
      $(this).closest(".row").find("i").css("display","none")

# 输入某项价格 ，自动check
  $("body").on "blur", ".row input[type='text']", (e) ->
    val = $(this).val()
    if val
      $(this).closest(".row").find("input[type='checkbox']").attr("value",1)
      $(this).closest(".row").find("input[type='checkbox']").checkboxX('refresh')
      $(this).closest(".row").find("input[type='checkbox']").trigger('change')

  # resend confirmation mail
  $('#resend-confirmation-mail').on 'click', (e) ->
    e.preventDefault()
    $.ajax
      url: '/kols/resend_confirmation_mail'
      type: 'GET'
      dataType: 'json'
      success: (data, textStatus, jqXHR) ->
        if data.message == 'success'
          $.growl 'Send confirmation success', {type: 'success'}
        else if data.message == 'already confirmed'
          $.growl 'Already confirmed', {type: 'danger'}
        else if data.message == 'slow down'
          $.growl 'Too fequently, slow down', {type: 'danger'}

      error: (jqXHR, textStatus, errorThrown) ->
        $.growl 'Something went wrong', {type: 'danger'}

