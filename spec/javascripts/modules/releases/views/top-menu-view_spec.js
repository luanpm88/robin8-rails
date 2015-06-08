describe('Releases.TopMenuView', function() {
  var newsroom;

  beforeEach(function() {
    newsroom = Factory.build("newsroom");
    newsroomCollection = new Robin.Collections.NewsRooms();
    newsroomCollection.push(newsroom);

    this.newsroomsFetchStub = 
          sinon.stub(Robin.Collections.NewsRooms.prototype, 'fetch')
              .yieldsTo('success', newsroomCollection);

    model = Factory.build("release");
    view = new Releases.TopMenuView({ model: model });
    Robin.user = new Robin.Models.User();
  });

  afterEach(function() {
    this.newsroomsFetchStub.restore();
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
      spyOn( view, 'extractURL');
      spyOn( view, 'highlightReleaseText');
      spyOn( view, 'startSmartRelease');
      spyOn( view.modelBinder, 'bind');
      spyOn( view, 'initFormValidation');
      spyOn( view, 'initLogoView');
      spyOn( view, 'initMediaTab');
      view.delegateEvents();
      view.render();
    });

    it("should fetch newsroom", function() {
      expect(view.newsrooms.fetch).toHaveBeenCalled;
    });

    describe('when fetch newsrooms', function() {
      
      it('should have newsroom in select', function() {
        expect(view.$el.find('#newsroom_filter')[0][1].innerHTML).toEqual('Test newsroom');
      });
    });

    it('should call model binder', function() {
      expect(view.modelBinder.bind).toHaveBeenCalledWith(model, view.el);
    });

    it('should call initFormValidation', function() {
      expect(view.initFormValidation).toHaveBeenCalled();
    });

    it('should define editor', function() {
      expect(view.editor).toBeDefined();
    });

    it('should call initLogoView', function() {
      expect(view.initLogoView).toHaveBeenCalled();
    });

    it('should call initMediaTab', function() {
      expect(view.initMediaTab).toHaveBeenCalled();
    });



  });


});
