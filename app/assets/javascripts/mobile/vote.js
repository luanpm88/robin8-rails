$(document).ready(function() {
  if ($('body').attr('id') === 'mobile_pages_vote') {
    var kol_token = $('#kol_token').val();
    var init_page = 1;

    var $vote_countdown = $('#vote_countdown');
    var countdown_datetime = $vote_countdown.data('datetime');
    countDownTimer($vote_countdown, countdown_datetime);

    var $tab_control = $('.user-info-panel');
    $tab_control.find('.tab-ctrl').on('click', '.item', function(){
      var $that = $(this),
          index = $that.index(),
          $tags = $tab_control.find('.tab-ctrl'),
          $content = $tab_control.find('.tab-content');
      $that.siblings('.item').removeClass('active');
      $that.addClass('active');
      $content.eq(index).siblings('.tab-content').removeClass('active');
      $content.eq(index).addClass('active');
    });

    if (init_page < 2) {
      $('#idols_list_prev').hide()
    } else {
      $('#idols_list_prev').show()
    }
    renderIdolsList(kol_token, init_page);

    $('#idols_list_prev').click(function(event) {
      if (init_page <= 2) {
        $('#idols_list_prev').hide()
      }
      if (init_page <= 1) {
        return
      }
      init_page -= 1;
      console.log(init_page);
      renderIdolsList(kol_token, init_page);
    });

    $('#idols_list_next').click(function(event) {
      init_page += 1;
      console.log(init_page);
      renderIdolsList(kol_token, init_page);
      if (init_page < 2) {
        $('#idols_list_prev').hide()
      } else {
        $('#idols_list_prev').show()
      }
    });
  }
});

function renderIdolsList(token, page) {
  $.ajax({
    url: '/api/v2_1/kols/my_idois',
    type: 'GET',
    data: {
      page: page
    },
    beforeSend: function(xhr) {
      xhr.setRequestHeader('Authorization', token);
    },
    success: function(data) {
      console.log(data);
      var _list = data.list;
      $('#idols_list').empty();
      if (_list.length > 0) {
        $.each(_list, function(index, el) {
          $('#idols_list').append(createIdolItem(el));
        });
      }
      if (_list.length > 3) {
        $('#idols_list_next').show()
      } else {
        $('#idols_list_next').hide()
      }
    },
    error: function(xhr, type) {
      console.log(xhr);
      console.log(type);
    }
  });
}

function createIdolItem(data) {
  var _data = data,
      id = _data.id,
      is_hot = _data.is_hot,
      name = _data.name,
      vote_ranking = _data.vote_ranking,
      avatar_url = _data.avatar_url;

  var $item = $('<li class="media item">' +
                  '<div class="media-left media-middle">' +
                    '<div class="avatar">' +
                      '<img src="'+ avatar_url +'" alt="" class="avatar-img" />' +
                    '</div>' +
                  '</div>' +
                  '<div class="media-body media-middle idol-info">' +
                    '<h5 class="name">'+ name +'</h5>' +
                    '<p>票数：'+ is_hot +'</p>' +
                    '<p>排名：'+ vote_ranking +'</p>' +
                  '</div>' +
                  '<div class="media-right media-middle">' +
                    '<div class="btn-area"></div>' +
                  '</div>' +
                '</li>');

  var $share_btn = $('<button type="button" class="btn">拉票</button>');
  var $vote_btn = $('<button type="button" class="btn">投票</button>');

  $item.find('.btn-area').append($vote_btn, $share_btn);

  return $item;
}
