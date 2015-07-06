Factory.define('stream', Robin.Models.Stream)
  .attr('id', 1)
  .attr('created_at', function() { return new Date(); })
  .attr('name', 'Facebook')
  .attr('sort_column', 'shares_count')
  .attr('user_id', 1)
  .attr('position', 2)

