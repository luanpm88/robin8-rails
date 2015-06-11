describe('Releases.ItemView', function() {

  beforeEach(function() {
    this.model = new Robin.Models.Release();
    this.view = new Releases.ItemView({ model: this.model });
    Robin.user = new Robin.Models.User();
  });

  it('should have template', function() {
    expect(this.view.template).not.toEqual(undefined);
  });

  it('should have events', function() {
    expect(this.view.events).toEqual(jasmine.objectContaining({ 
      'click #open_edit': 'openEditModal' 
    }));
    expect(this.view.events).toEqual(jasmine.objectContaining({ 
      'click #start-blast': 'startSmartRelease'
    }));
  });

  describe('initialize:', function() {

    it('should set first_src', function() {
      expect(this.model.attributes.first_src).not.toEqual('');
    });
  });

  describe('onRender', function() {
    
    beforeEach(function() {
       this.view.render();
    });

    it('should add class disabled-unavailable for #start-blast', function() {
      expect(this.view.$el.find("#start-blast").attr('class')).toContain('disabled-unavailable');
    });
  });

  describe('onShow', function() {

    it('should be defined', function() {
      expect(this.view.onShow).toBeDefined();
    });
  });

  describe('startSmartRelease', function() {
    
    it('should be defined', function() {
      expect(this.view.startSmartRelease).toBeDefined();
    });
  });

  describe('openEditModal', function() {

    it('should be defined', function() {
      expect(this.view.startSmartRelease).toBeDefined();
    });
  });
});
