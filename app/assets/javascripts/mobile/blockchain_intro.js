$(document).ready(function() {
  if ($('body').attr('id') === 'wechat_pages_blockchain_intro') {
    $('#blockchain_open_btn').click(function(event) {
      if (typeof jwPut != 'undefined') {
        jwPut.put_begin();
      }
    });
  }
});
