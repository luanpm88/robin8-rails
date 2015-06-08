describe('Robin.Monitoring.Show.StoryItemView spec', function () {
  var view, model, modelStream, collection, viewview;
  Robin.user = new Robin.Models.User();

  beforeEach(function () {
    model = Factory.build("story");
    modelStream = Factory.build("stream");
    collection = new Robin.Collections.Stories();
    collection.push(model);

    Robin.cachedStories[1] = collection;


    view = new Robin.Monitoring.Show.StreamCompositeView({model: modelStream});
  });

  afterEach(function () {
    // model.clear();
    Robin.cachedStories[1] = undefined; 
    Robin.loadingStreams = [];
    collection.reset();
  });

  describe('when view is initializing', function () {
    it ('should exist', function () {
      expect(view).toBeDefined();
    });
  });

  describe('when view is rendered', function () {

    beforeEach(function () {
      view.render();
    });

    describe ("describe", function () {
      beforeEach(function () {
        viewview = _.values(view.children._views)[0];
        spyOn( viewview, 'openStory');
        spyOn( viewview, 'shareStory');
        viewview.delegateEvents();
        // viewview.render();
      });

      // it ("bla", function () {
        // viewview.$el.find('.read-more').click();
        // expect(viewview.openStory).toHaveBeenCalled();
      // });
    });

    // it ("should call sharing story action", function () {
    //   view.$el.find('.share').click();
    //   expect(view.openStory).toHaveBeenCalled();
    // });
  });

});
