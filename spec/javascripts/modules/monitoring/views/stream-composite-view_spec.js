describe('Robin.Monitoring.Show.StreamsCompositeView spec', function () {
  var view, model;
  Robin.user = new Robin.Models.User();

  beforeEach(function () {
    model = new Robin.Models.Stream();
    model.set('position', 1);
   //  var topics = [];
   //  var newTopic =  {
   //            id: 'Facebook',
   //            text: 'Facebook'
   //          };
   //  topics.push(newTopic);
   //  model.set("topics", topics);

   // // spyOn(model, 'save').andCallThrough();

    view = new Robin.Monitoring.Show.StreamCompositeView({model: model});
  });

  describe('when view is initializing', function () {

    it ('should exist', function () {
      expect(view).toBeDefined();
    });

  });

  describe('when view is rendered', function () {

    beforeEach(function () {
      view.render();
    });

    it ('should have initial title', function () {
      expect(view.$el.find('#title').text()).toEqual('Untitled Stream');
    });

    it ('should not be available editable title', function () {
        expect(view.$el.find('.stream-header .editableform').length).toEqual(0);
      });

    describe ('when user click title', function () {
      // beforeEach(function () {
      // });

      it ('should appear editable title', function () {
        view.$el.find('#titeele').click();
        expect(view.$el.find('.stream-header .editableform').length).toEqual(0);
      });

      it ('should edit title', function () {
        view.$el.find('#title').click();
        view.$el.find('.stream-header .editableform .edit-title').val('Title1');
        console.log(view.$el.find('.stream-header .editableform .edit-title').val());
        view.$el.find('.editable-submit').click();
        expect(view.$el.find('.stream-header .editableform').length).toEqual(0);
      });
    });


  });
});