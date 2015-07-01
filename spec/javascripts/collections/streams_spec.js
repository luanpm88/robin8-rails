describe('Robin.Collections.Streams', function() {

  it('should be defined', function() {
    expect(Robin.Collections.Streams).toBeDefined();
  });

  it('can be instantiated', function() {
    var streams = new Robin.Collections.Streams();
    expect(streams).not.toBeNull();
  });
});
