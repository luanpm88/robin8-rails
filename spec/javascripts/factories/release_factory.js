Factory.define('release', Robin.Models.Release)
  .sequence('id')
  .attr('created_at', function() { return new Date(); })
  .attr('title', 'Test release')
  .attr('user_id', 1)
  .attr('slug', 'test-release')
  .attr('text', 'Test release text')
  .attr('news_room_id', 1);
