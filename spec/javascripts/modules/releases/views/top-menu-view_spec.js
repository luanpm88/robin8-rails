describe('Releases.TopMenuView', function() {
  var newsroom, view, model;
  Robin.user = new Robin.Models.User();

  beforeEach(function() {
    newsroom = Factory.build("newsroom");
    newsroomCollection = new Robin.Collections.NewsRooms();
    newsroomCollection.push(newsroom);

    this.newsroomsFetchStub = 
          sinon.stub(Robin.Collections.NewsRooms.prototype, 'fetch')
              .yieldsTo('success', newsroomCollection);

    model = Factory.build("release");
    view = new Releases.TopMenuView({ model: model });
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
      spyOn( view, 'deleteRelease');
      spyOn( view, 'extractURL');
      spyOn( view, 'makeNewsRoomPublic');
      spyOn( view, 'newsRoomSelected');
      spyOn( view, 'startSmartRelease');
      spyOn( view.modelBinder, 'bind');
      spyOn( view, 'initFormValidation');
      spyOn( view, 'initLogoView');
      spyOn( view, 'initMediaTab');
      spyOn( view, 'changePrivate');
      spyOn( view, 'uploadDirectImage');
      spyOn( view, 'uploadUrlImage');
      spyOn( view, 'uploadDirectVideo');
      spyOn( view, 'uploadUrlVideo');
      spyOn( view, 'insertLink');
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

    it('when click .private-checkbox should call changePrivate', function() {
      view.$el.find('.private-checkbox').iCheck('check');
      expect(view.changePrivate).toHaveBeenCalled();
    });

    it('when click #new_release should call openModalDialog', function() {
      view.$el.find('#new_release').click();
      expect(view.openModalDialog).toHaveBeenCalled();
    });

    it('when click #newsroom_filter should call filterBy', function() {
      view.$el.find('#newsroom_filter').click();
      expect(view.filterBy).toHaveBeenCalled();
    });

    it('when click #save_release should call saveRelease', function() {
      view.$el.find('#save_release').click();
      expect(view.saveRelease).toHaveBeenCalled();
    });

    it('when click #delete_release should call deleteRelease', function() {
      view.$el.find('#delete_release').click();
      expect(view.deleteRelease).toHaveBeenCalled();
    });

    it('when click #extract_url should call extractURL', function() {
      view.$el.find('#extract_url').click();
      expect(view.extractURL).toHaveBeenCalled();
    });

    it('when click #smart_release call startSmartReleasehighlightReleaseText', function() {
      view.$el.find('#smart_release').click();
      expect(view.startSmartRelease).toHaveBeenCalled();
    });

    it('when click #make-public call makeNewsRoomPublic', function() {
      view.$el.find('#make-public').click();
      expect(view.makeNewsRoomPublic).toHaveBeenCalled();
    });

    it('change newsroom', function() {
      view.$el.find('#news_room_id').val('1').trigger('change');
      expect(view.newsRoomSelected).toHaveBeenCalled();
    });

    it('when click #direct-image-upload call uploadDirectImage', function() {
      view.$el.find('#direct-image-upload').click();
      expect(view.uploadDirectImage).toHaveBeenCalled();
    });
    
    it('when click #url-image-upload call uploadUrlImage', function() {
      view.$el.find('#url-image-upload').click();
      expect(view.uploadUrlImage).toHaveBeenCalled();
    });
    
    it('when click #direct-video-upload call uploadDirectVideo', function() {
      view.$el.find('#direct-video-upload').click();
      expect(view.uploadDirectVideo).toHaveBeenCalled();
    });
    
    it('when click #url-video-upload call uploadUrlVideo', function() {
      view.$el.find('#url-video-upload').click();
      expect(view.uploadUrlVideo).toHaveBeenCalled();
    });
    
    it('when click #insert_link call insertLink', function() {
      view.$el.find('#insert_link').click();
      expect(view.insertLink).toHaveBeenCalled();
    });

    it('wysihtml5 params must be defined', function() {
      expect(view.ui.wysihtml5.wysihtml5).toBeDefined();
    });

    it('html editor must be set', function() {
      expect(view.editor).toBeDefined();
    });

  });
});
