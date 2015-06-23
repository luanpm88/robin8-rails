describe('Robin.Models.NewsRoom', function() {
  it('should be defined', function() {
    expect(Robin.Models.NewsRoom).toBeDefined();
  });

  it('can be instantiated', function() {
    var newsRoom = new Robin.Models.NewsRoom();
    expect(newsRoom).not.toBeNull();
  });

  beforeEach(function() {
    this.newsRoom = new Robin.Models.NewsRoom();
  });

});