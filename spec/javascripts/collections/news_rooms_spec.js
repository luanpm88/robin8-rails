describe('Robin.Collections.NewsRooms', function() {

  it('should be defined', function() {
    expect(Robin.Collections.NewsRooms).toBeDefined();
  });

  it('can be instantiated', function() {
    var newsRooms = new Robin.Collections.NewsRooms();
    expect(newsRooms).not.toBeNull();
  });
});
