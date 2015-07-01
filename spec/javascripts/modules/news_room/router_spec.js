describe('NewsRoom.Router', function() {
  
  beforeEach(function() {
    try {
      Backbone.history.start({
        silent: true,
        pushState: true
      });
    } catch (e) {}

    RobinControllerMock = Marionette.Controller.extend({
      index: function() {},
    });

    Newsroom = Robin.module("Newsroom");

    this.routeSpy = sinon.spy();
    this.router = new Newsroom.Router({
      controller: new RobinControllerMock()
    });
  });

  afterEach(function() {
    'use strict';
    Backbone.history.stop();
  });

  it('can navigate to #news_rooms', function() {
    this.router.bind('route:index', this.routeSpy);
    this.router.navigate('news_rooms', true);
    expect(this.routeSpy.calledOnce).toBeTruthy();
  });
 
});