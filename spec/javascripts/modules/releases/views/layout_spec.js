describe('Releases.Layout', function() {
  
  beforeEach(function() {
    this.model = new Robin.Models.Release();
    this.view = new Releases.Layout({ model: this.model });
  });

  it('should be defined', function() {
    expect(this.view).toBeDefined;
  });

  it('should have template', function() {
    expect(this.view.template).not.toBe(undefined);
  });

  it('should have regions ', function() {
    expect(this.view.regions).not.toBe(undefined);
  });

});
