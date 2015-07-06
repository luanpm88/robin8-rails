describe('Robin.Models.Release', function() {
  it('should be defined', function() {
    expect(Robin.Models.Release).toBeDefined();
  });

  it('can be instantiated', function() {
    var release = new Robin.Models.Release();
    expect(release).not.toBeNull();
  });

  beforeEach(function() {
    this.release = new Robin.Models.Release();
  });

  describe('new instance default values', function() {

    it('has default value for the .views attribute', function() {
      expect(this.release.get('views')).toEqual('5.2k');
    });

    it('has default value for the .likes attribute', function() {
      expect(this.release.get('likes')).toEqual(223);
    });

    it('has default value for the .coverages attribute', function() {
      expect(this.release.get('coverages')).toEqual(3);
    });
  });
});
