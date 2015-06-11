describe('Robin.Models.Stream', function() {
  it('should be defined', function() {
    expect(Robin.Models.Stream).toBeDefined();
  });

  it('can be instantiated', function() {
    var stream = new Robin.Models.Stream();
    expect(stream).not.toBeNull();
  });

  beforeEach(function() {
    this.stream = new Robin.Models.Stream();
  });

  describe('new instance default values', function() {

    it('has default value for name attribute', function() {
      expect(this.stream.get('name')).toEqual('Untitled Stream');
    });

    it('has default value sort_column attribute', function() {
      expect(this.stream.get('sort_column')).toEqual('shares_count');
    });
  });
});
