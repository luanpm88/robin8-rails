describe('Robin.Collections.Releases', function() {

  it('should be defined', function() {
    expect(Robin.Collections.Releases).toBeDefined();
  });

  it('can be instantiated', function() {
    var releases = new Robin.Collections.Releases();
    expect(releases).not.toBeNull();
  });
});
