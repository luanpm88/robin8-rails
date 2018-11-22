$(document).ready(function() {
  if ($('body').attr('id') === 'mobile_pages_vote_detail') {
    var kol_token = $('#kol_token').val();
    var APIURL = '/api/v2_1/kols/my_voters';
    var data_params = {};
    var dropLoadCtrl;

    data_params.per_page = 10;
    data_params.page = 0;
    dropLoadCtrl = new DropLoadCtrl(
      '#voter_list',
      '.rank-list',
      APIURL,
      data_params,
      kol_token,
      'list',
      createVoterItem,
      ''
    );
  }
});

function createVoterItem(data, index) {
  var _data = data,
      id = _data.voter_id,
      count = _data.count,
      name = _data.voter_name,
      avatar_url = _data.voter_avatar,
      updated_at = _data.updated_at,
      rank_icon = '';
  var assets_url = ''
  switch (index) {
    case 0:
      rank_icon = '<div class="rank-icon first"></div>';
      break;
    case 1:
      rank_icon = '<div class="rank-icon second"></div>';
      break;
    case 2:
      rank_icon = '<div class="rank-icon third"></div>';
      break;
    default:
      rank_icon = '<div class="rank-icon">'+ index + 1 +'</div>';
  }

  var _ui = '<li class="item">' +
              rank_icon +
              '<div class="media rank-body">' +
                '<div class="media-left media-middle">' +
                  '<div class="avatar">' +
                    '<img src="'+ avatar_url +'" alt="" class="avatar-img" />' +
                  '</div>' +
                '</div>' +
                '<div class="media-body media-middle">' +
                  '<p class="name">'+ name +'</p>' +
                  '<p>3天前</p>' +
                '</div>' +
                '<div class="media-right media-middle">' +
                  '<p class="statistics">'+ count +'票</p>' +
                '</div>' +
              '</div>' +
            '</li>';

  return _ui;
}
