describe('Robin.module Releases.Router', function() {
  
  beforeEach(function() {
    try {
      Backbone.history.start({
        silent: true,
        pushState: true
      });
    } catch (e) {}

    RobinControllerMock = Marionette.Controller.extend({
      index: function() {},
      indexBy: function() {}
    });

    Releases = Robin.module("Releases");
    Releases.start();

    this.routeSpy = sinon.spy();
    this.router = new Releases.Router({
      controller: new RobinControllerMock()
    });
  });

  afterEach(function() {
    'use strict';
    Backbone.history.stop();
    Releases.stop();
  });

  it('can navigate to #releases', function() {
    this.router.bind('route:index', this.routeSpy);
    this.router.navigate('releases', true);
    expect(this.routeSpy.calledOnce).toBeTruthy();
  });

  it('can navigate to #releases/newsroom/:id', function() {
    this.router.bind('route:indexBy', this.routeSpy);
    this.router.navigate('releases/newsroom/1', true);
    expect(this.routeSpy.calledOnce).toBeTruthy();
    expect(this.routeSpy.calledWith('1')).toBeTruthy();
  });
});
