$(document).ready(function() {
  if ($('body').attr('id') === 'mobile_pages_blockchain_intro') {
    $('#blockchain_open_btn').click(function(event) {
      if (typeof jwPut != 'undefined') {
        jwPut.put_begin();
      }
    });
  }
});
