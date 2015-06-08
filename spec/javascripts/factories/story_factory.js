Factory.define('story', Robin.Models.Story)
  .sequence('id')
  .attr('author_id', 452513)
  .attr('author_name', "Yvette D'entremont")
  .attr('blog_id', 14)
  .attr('blog_name', "Gawker")
  .attr('published_at', "2015-04-06T19:53:47Z")
  .attr('description', "Vani Hari, a.k.a. the Food Babe, has amassed a loyal following in her Food Babe Army. The recent subject of profiles and interviews in the New York Times, the New York")
  .attr('images', function() {
    return ["http://i.kinja-img.com/gawker-media/image/upload/s--687mSmfs--/ydgfebsxebqooafqomyn.jpg"
    ];
  })
  .attr('link', "http://gawker.com/the-food-babe-blogger-is-full-of-shit-1694902226")
  .attr('title', "The Food Babe Blogger Is Full of Shit")
  .attr('shares_count', function() {
    return {facebook: 1000, twitter: 1000, google_plus: 1000, linkedin: 1000};
  })
