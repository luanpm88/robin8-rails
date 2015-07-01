describe('Releases.CollectionView', function() {

  beforeEach(function() {
    this.view = new Releases.CollectionView;
  });

  it('should have tagName', function() {
    expect(this.view.tagName).not.toEqual(undefined);
  });

  it('should have className', function() {
    expect(this.view.className).not.toEqual(undefined);
  });

  describe('arrangeReleases', function() {

    it('should be defined', function() {
      expect(this.view.arrangeReleases).toBeDefined();
    });

    it('should set highest height', function() {
      $('<div class="releases-view"><div class="release-item"><img height="100px"></div><div class="release-item"><img height="200px"></div><div class="release-item"><img height="100px"></div></div>').appendTo('body');
      $('.releases-view').width(1000);
      this.view.arrangeReleases();
      expect($('.release-item').height()).toEqual(205);
    });

  });
});
