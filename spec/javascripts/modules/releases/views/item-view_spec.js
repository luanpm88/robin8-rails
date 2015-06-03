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

    it('should remove class disabled-unavailable for #start-blast', function() {
      $('<a href="#" class="disabled-unavailable" role="button" data-toggle="modal" style="margin-left: 5px;" id="start-blast"><i class="fa fa-rocket"></i> SmartRelease</a>').appendTo('body');
      console.info($("#start-blast").attr('class').split(' '));
      this.view.onRender();
      console.info($("#start-blast").attr('class').split(' '));
    });
  });

});
