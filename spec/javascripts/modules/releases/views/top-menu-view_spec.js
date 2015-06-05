describe('Releases.TopMenuView', function() {

  beforeEach(function() {
    model = Factory.build("release");
    view = new Releases.TopMenuView({ model: model });
    Robin.user = new Robin.Models.User();
  });

  describe('when view is initializing', function () {

    it ('should exist', function () {
      expect(view).toBeDefined();
    });

    it('should have template', function() {
      expect(view.template).toBeDefined();
    });

    it('should have className', function() {
      expect(view.className).toBeDefined();
    });

    it('should have regions', function() {
      expect(view.regions).toBeDefined();
    });

    it('should have ui', function() {
      expect(view.ui).toBeDefined();
    });

    it('should have events', function() {
      expect(view.events).toBeDefined();
    });
  });

  describe('when view is rendered', function () {
    beforeEach(function() {
      spyOn( view, 'openModalDialog');
      spyOn( view, 'filterBy');
      spyOn( view, 'saveRelease');
      spyOn( view, 'refreshTimeRangeVisibility');
      spyOn( view, 'extractURL');
      spyOn( view, 'highlightReleaseText');
      spyOn( view, 'startSmartRelease');
      view.delegateEvents();
      view.render();
    });
  });

  // TODO!!!
});
