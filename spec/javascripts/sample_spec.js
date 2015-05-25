describe('RegExp', function(){
  it('should match', function(){
    // expect('string').toMatch(new RegExp('^string$'));
    expect('string').toMatch(new RegExp('^string$'));
  })

  it("should expose an attribute", function() {
    var episode = new Backbone.Model({
      title: "Hollywood - Part 2"
    });
    expect(episode.get("title"))
      .toEqual("Hollywood - Part 2");
  });
});

describe("Sinon example test", function () {
  var time2013_10_01;

  time2013_10_01 = (new Date(2013, 10-1, 1)).getTime();

  beforeEach(function() {
    // sinon was defined in global scope 
    this.fakeTimer = new sinon.useFakeTimers(time2013_10_01);
  });

  it("some test", function() {
    //test 
  });

  afterEach(function() {
    this.fakeTimer.restore();
  });
});
