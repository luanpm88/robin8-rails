describe('Robin.Monitoring.Show.StreamsCompositeView spec', function () {
  var view, model;

  beforeEach(function () {
    model = Factory.build("stream");
    Robin.cachedStories[1] = undefined;

    view = new Robin.Monitoring.Show.StreamCompositeView({model: model});
  });

  describe('when view is initializing', function () {

    it ('should exist', function () {
      expect(view).toBeDefined();
    });

    it ('should have template', function () {
      expect(view.template).toBeDefined();
    });

    it ('should have tagName', function () {
      expect(view.tagName).toBeDefined();
    });

    it ('should have className', function () {
      expect(view.className).toBeDefined();
    });

    it ('should have childViewContainer', function () {
      expect(view.childViewContainer).toBeDefined();
    });

  });

  describe('when view is rendered', function () {

    beforeEach(function () {
      spyOn( view, 'closeStream');
      spyOn( view, 'settings'); //
      spyOn( view, 'toggleRssDialog'); //
      spyOn( view, 'closeSettings');
      spyOn( view, 'done');
      spyOn( view, 'editTitle');
      spyOn( view, 'updateTitle');
      spyOn( view, 'showNewStories');
      spyOn( view, 'loadInfo'); //
      spyOn( view, 'selectLink');
      spyOn( view, 'makeKeyword');
      spyOn( view, 'refreshTimeRangeVisibility'); //
      spyOn( view.modelBinder, 'bind'); //
      spyOn( view.model, 'save');
      spyOn( Robin.user, 'get').and.returnValue(true);
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

    it ("should close stream", function () {
      view.$el.find('.stream-header .delete-stream').click();
      expect(view.closeStream).toHaveBeenCalled();
    });

    it('should make keywords', function() {
      view.$el.find('.make-keyword').click();
      expect(view.makeKeyword).toHaveBeenCalled();
    });

    it('should behave select link', function() {
      view.$el.find('.rss-input').click();
      expect(view.selectLink).toHaveBeenCalled();
    });

    it('should show news stories', function() {
      view.$el.find('.js-show-new-stories').click();
      expect(view.showNewStories).toHaveBeenCalled();
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
        expect(view.editTitle).toHaveBeenCalled();
      });

      it ("shouldn't edit title", function () {
        view.$el.find('#title').click();
        view.$el.find('.stream-header .editableform .edit-title').val('Title1');
        view.$el.find('.editable-cancel').click();
        expect(view.model.save).not.toHaveBeenCalled();
      });
    });

    it('Robin user get can create stream', function() {
      expect(Robin.user.get).toBeDefined();
    });

  });
});
