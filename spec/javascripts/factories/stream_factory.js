Factory.define('stream', Robin.Models.Stream)
  .sequence('id')
  .attr('created_at', function() { return new Date(); })
  .attr('name', 'Facebook')
  .attr('sort_column', 'shares_count')
  .attr('user_id', 1)
  .attr('position', 2)
  .attr('topics', function() {
    return [
      { 
        id: "Facebook",
        text: "Facebook"
      }
    ];
  });
