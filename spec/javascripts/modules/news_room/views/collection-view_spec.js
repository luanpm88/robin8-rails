describe('NewsRoom.CollectionView', function() {

  beforeEach(function() {
    this.view = new Newsroom.CollectionView;
  });

  it('should have tagName', function() {
    expect(this.view.tagName).not.toEqual(undefined);
  });

  it('should have className', function() {
    expect(this.view.className).not.toEqual(undefined);
  });
});