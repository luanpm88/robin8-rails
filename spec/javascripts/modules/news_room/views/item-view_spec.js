describe('NewsRoom.ItemView', function() {

  beforeEach(function() {
    this.model = new Robin.Models.NewsRoom();
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
  });

});
