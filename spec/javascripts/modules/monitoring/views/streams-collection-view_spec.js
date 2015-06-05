describe('Robin.Monitoring.Show.StreamsCollectionView spec', function () {
  var view, model;

  beforeEach(function () {
    view = new Robin.Monitoring.Show.StreamsCollectionView();
  });

  describe('when view is constructing', function () {

    it ('should exist', function () {
      expect(view).toBeDefined();
    });

  });

  // describe('when view is rendered', function () {

  //   beforeEach(function () {
  //       view.render();
  //   });

  //   it ('should have class stream container', function () {
  //       console.log(view.$el.attr('class').split(' '));
  //       expect(view.$el).toHaveClass('stream-container');
  //   });

  //   // it ('should website field be empty', function () {
  //   //     expect(view.$el.find('input#website')).toHaveValue('');
  //   // });

  //   // it ('should feedback field with default feedback', function () {
  //   //     expect(view.$el.find('textarea#feedback')).toHaveValue('TDD is awesome..');
  //   // });

  // });
});