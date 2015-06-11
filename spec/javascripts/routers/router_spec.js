describe('Robin.Routers.AppRouter appRoutes', function() {

  beforeEach(function() {
    try {
      Backbone.history.start({
        silent: true,
        pushState: true
      });
    } catch (e) {}

    RobinControllerMock = Marionette.Controller.extend({
      showDashboard: function() {},
      showRobin: function() {},
      showManageUsers: function() {},
      showMonitoring: function() {},
      showNewsRooms: function() {},
      showReleases: function() {},
      showSocial: function() {},
      showAnalytics: function() {},
      showProfile: function() {},
      showBilling: function() {},
      showRecommendations: function() {}
    });

    this.routeSpy = sinon.spy();
    this.router = new Robin.Routers.AppRouter({
      controller: new RobinControllerMock()
    });
  });

  afterEach(function() {
    'use strict';
    Backbone.history.stop();
  });

  it('should be defined and able to create test objects', function() {
    expect(this.router).toBeDefined();
  });

  it('has the right amount of routes', function() {
    expect(_.size(this.router.appRoutes)).toEqual(12);
  });

  it('can navigate to #dashboard', function() {
    this.router.bind('route:showDashboard', this.routeSpy);
    this.router.navigate('dashboard', true);
    expect(this.routeSpy.calledOnce).toBeTruthy();
  });

  it('can navigate to #dashboard (empty "")', function() {
    this.router.bind('route:showDashboard', this.routeSpy);
    this.router.navigate('', true);
    expect(this.routeSpy.calledOnce).toBeTruthy();
  });

  it('can navigate to #robin8', function() {
    this.router.bind('route:showRobin', this.routeSpy);
    this.router.navigate('robin8', true);
    expect(this.routeSpy.calledOnce).toBeTruthy();
  });

  it('can navigate to #manage_users', function() {
    this.router.bind('route:showManageUsers', this.routeSpy);
    this.router.navigate('manage_users', true);
    expect(this.routeSpy.calledOnce).toBeTruthy();
  });

  it('can navigate to #monitoring', function() {
    this.router.bind('route:showMonitoring', this.routeSpy);
    this.router.navigate('monitoring', true);
    expect(this.routeSpy.calledOnce).toBeTruthy();
  });

  it('can navigate to #news_rooms', function() {
    this.router.bind('route:showNewsRooms', this.routeSpy);
    this.router.navigate('news_rooms', true);
    expect(this.routeSpy.calledOnce).toBeTruthy();
  });

  it('can navigate to #releases', function() {
    this.router.bind('route:showReleases', this.routeSpy);
    this.router.navigate('releases', true);
    expect(this.routeSpy.calledOnce).toBeTruthy();
  });

  it('can navigate to #social', function() {
    this.router.bind('route:showSocial', this.routeSpy);
    this.router.navigate('social', true);
    expect(this.routeSpy.calledOnce).toBeTruthy();
  });

  it('can navigate to #analytics', function() {
    this.router.bind('route:showAnalytics', this.routeSpy);
    this.router.navigate('analytics', true);
    expect(this.routeSpy.calledOnce).toBeTruthy();
  });

  it('can navigate to #profile', function() {
    this.router.bind('route:showProfile', this.routeSpy);
    this.router.navigate('profile', true);
    expect(this.routeSpy.calledOnce).toBeTruthy();
  });

  it('can navigate to #billing', function() {
    this.router.bind('route:showBilling', this.routeSpy);
    this.router.navigate('billing', true);
    expect(this.routeSpy.calledOnce).toBeTruthy();
  });

  it('can navigate to #recommendations', function() {
    this.router.bind('route:showRecommendations', this.routeSpy);
    this.router.navigate('recommendations', true);
    expect(this.routeSpy.calledOnce).toBeTruthy();
  });
});
