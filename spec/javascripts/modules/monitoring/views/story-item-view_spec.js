describe('Robin.Monitoring.Show.StoryItemView spec', function () {
  var view, model, modelStream, collection, viewChild;
  Robin.user = new Robin.Models.User();

  beforeEach(function () {
    model = Factory.build("story");
    modelStream = Factory.build("stream");
    collection = new Robin.Collections.Stories();
    collection.push(model);

    Robin.cachedStories[modelStream.get('id')] = collection;

    view = new Robin.Monitoring.Show.StreamCompositeView({model: modelStream});
  });

  describe('when view is initializing', function () {
    it ('should exist', function () {
      expect(view).toBeDefined();
    });
  });

  describe('when composite view is rendered', function () {

    beforeEach(function () {
      view.render();
    });

    describe ("when child view is rendered", function () {
      beforeEach(function () {
        viewChild = _.values(view.children._views)[0];
        spyOn( viewChild, 'openStory');
        spyOn( viewChild, 'shareStory');
        viewChild.delegateEvents();
        viewChild.render();
      });

      it ("should call open story action", function () {
        viewChild.$el.find('.js-open-story').click();
        expect(viewChild.openStory).toHaveBeenCalled();
      });
      
      it ("should call sharing story action", function () {
        viewChild.$el.find('.share').click();
        expect(viewChild.shareStory).toHaveBeenCalled();
      });

      it ("should have correct number of shares", function () {
        expect(viewChild.$el.find('.media-body .likes a').text()).toEqual(' 4000');
      });

      it ("should have correct title", function () {
        expect(viewChild.$el.find('p.js-open-story').text()).toEqual('The Food Babe Blogger Is Full of Shit');
      });

      it ("should have correct image url", function () {
        expect(viewChild.$el.find('img.image').attr('src')).toEqual('http://i.kinja-img.com/gawker-media/image/upload/s--687mSmfs--/ydgfebsxebqooafqomyn.jpg');
      });

    });

  });

});
