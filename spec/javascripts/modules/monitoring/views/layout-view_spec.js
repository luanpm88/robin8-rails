describe('Robin.Monitoring.Show.LayoutView spec', function () {
  var view, model, streams;

  beforeEach(function () {
    view = new Robin.Monitoring.Show.LayoutView();

    streams = new Robin.Collections.Streams();
    var stream = Factory.build("stream");
    streams.push(stream);
   
    streamsFetchStub = 
        sinon.stub(Robin.Collections.Streams.prototype, 'fetch')
           .yieldsTo('success', streams); 
    Robin.cachedStories[1] = streams;
  });

  afterEach(function() {
    streamsFetchStub.restore();
  });

  describe('when view is constructing', function () {
    it ('should exist', function () {
      expect(view).toBeDefined();
    });
  });

  describe('when view is rendered', function () {

    beforeEach(function () {
      spyOn( view, 'addStream');

      view.delegateEvents();
      view.render();
    });

    it ('should have class stream container', function () {
      view.$el.find('#add-stream').click();
      expect(view.addStream).toHaveBeenCalled();
    });

  });
});