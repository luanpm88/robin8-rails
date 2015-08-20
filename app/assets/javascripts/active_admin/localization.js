$(function(){

  $('.add-new-translation').on('click', function(event){
    var table = $('table.localization-table');
    var template = $(event.target).data('template');
    var length = table.find('.new-translation-row').length;
    var appendedTable = table.append($(template));
    appendedTable.find('tr:last .row-keys').attr('name', 'keys' + '[' + length + ']' + '[key]');
    appendedTable.find('tr:last .key-en-value').attr('name', 'keys' + '[' + length + ']' + '[en]');
    appendedTable.find('tr:last .key-zh-value').attr('name', 'keys' + '[' + length + ']' + '[zh]');
    event.preventDefault();
  });

  $( "table.localization-table tbody" ).on( "click", ".delete-translation", function() {
    console.log('deleted');
  });

});