describe('Releases.CharacteristicsView', function() {
  
  beforeEach(function() {
    this.view = new Releases.CharacteristicsView;
  });

  it('should have template', function() {
    expect(this.view.template).not.toBe(undefined);
  });

  it('should have modelEvents', function() {
    expect(this.view.modelEvents).not.toBe(undefined);
  });
});
