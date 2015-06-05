describe('Robin.Monitoring.Show.StreamsCompositeView spec', function () {
  var view, model;
  Robin.user = new Robin.Models.User();

  beforeEach(function () {
    model = Factory.build("stream");
    Robin.cachedStories[1] = undefined;

    view = new Robin.Monitoring.Show.StreamCompositeView({model: model});
  });

  describe('when view is initializing', function () {

    it ('should exist', function () {
      expect(view).toBeDefined();
    });

  });

  describe('when view is rendered', function () {

    beforeEach(function () {
      spyOn( view, 'toggleRssDialog');
      spyOn( view, 'settings');
      spyOn( view, 'loadInfo');
      spyOn( view.model, 'save');
      spyOn( view, 'refreshTimeRangeVisibility');
      spyOn( view.modelBinder, 'bind');
      view.delegateEvents();
      view.render();
    });

    it("should call loadInfo for topics", function() {
      expect(view.loadInfo).toHaveBeenCalledWith('topics');
    });

    it("should call loadInfo for blogs", function() {
      expect(view.loadInfo).toHaveBeenCalledWith('blogs');
    });

    it("should call refreshTimeRangeVisibility", function() {
      expect(view.refreshTimeRangeVisibility).toHaveBeenCalled();
    });

    it("should bind view.el", function() {
      expect(view.modelBinder.bind).toHaveBeenCalledWith(model, view.el);
    });

    it ('should have initial title', function () {
      expect(view.$el.find('#title').text()).toEqual('Facebook');
    });

    it ('should not be available editable title', function () {
      expect(view.$el.find('.stream-header .editableform').length).toEqual(0);
    });

    it ("should call settings action", function () {
      view.$el.find('.stream-header .settings-button').click();
      expect(view.settings).toHaveBeenCalled();
    });

    it ("should call rss dialog action", function () {
      view.$el.find('.stream-header .rss-button').click();
      expect(view.toggleRssDialog).toHaveBeenCalled();
    });

    describe ('when user click title', function () {

      it ('should appear editable title', function () {
        view.$el.find('#title').click();
        expect(view.$el.find('.stream-header .editableform').length).toEqual(1);
      });

      it ('should edit title', function () {
        view.$el.find('#title').click();
        view.$el.find('.stream-header .editableform .edit-title').val('Title1');
        view.$el.find('.editable-submit').click();
        expect(view.model.save).toHaveBeenCalled();
      });

      it ("shouldn't edit title", function () {
        view.$el.find('#title').click();
        view.$el.find('.stream-header .editableform .edit-title').val('Title1');
        view.$el.find('.editable-cancel').click();
        expect(view.model.save).not.toHaveBeenCalled();
      });
      
    });


  });
});