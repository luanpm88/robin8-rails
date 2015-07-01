describe('Robin.Monitoring.Show.StreamsCollectionView spec', function () {
  var view, model;

  beforeEach(function () {
    view = new Robin.Monitoring.Show.StreamsCollectionView();
  });

  describe('when view is constructing', function () {

    it ('should exist', function () {
      expect(view).toBeDefined();
    });

  });

  describe('when view is rendered', function () {

    beforeEach(function () {
        view.render();
    });

    it ('should have class stream container', function () {
      expect(view.$el.attr('class').split(' ')[0]).toEqual('stream-container');
    });

  });
});