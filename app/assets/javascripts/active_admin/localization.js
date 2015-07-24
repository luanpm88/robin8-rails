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
    var target = $(event.target),
        tr = target.closest('tr'),
        inputs = tr.find('input');
    inputs.attr('name', 'deleted_' + inputs.attr('name'));
    inputs.css('opacity', '.2');
    tr.find('.delete-translation').hide();
    tr.find('.undo-delete').show();
    event.preventDefault();
  });

  $( "table.localization-table tbody" ).on( "click", ".undo-delete", function() {
    var target = $(event.target),
        tr = target.closest('tr'),
        inputs = tr.find('input');
    inputs.attr('name', inputs.attr('name').replace('deleted_', ''));
    inputs.css('opacity', '1');
    tr.find('.undo-delete').hide();
    tr.find('.delete-translation').show();
    event.preventDefault();
  });

});