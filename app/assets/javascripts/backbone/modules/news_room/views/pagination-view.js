Robin.module('Newsroom', function(Newsroom, App, Backbone, Marionette, $, _){

  Newsroom.PaginationView = Marionette.ItemView.extend({
    template: 'modules/news_room/templates/pagination-view',
    pageOffset: 3,
    tagName: 'nav',
    attributes: {
      align: 'center'
    },
    modelEvents: {
      "change": "modelChanged"
    },
    events: {
      'click .page': 'setPage',
      'click .prev_page': 'prevPage',
      'click .next_page': 'nextPage'
    },
    templateHelpers: function () {
    return {
        leftEdge: this.leftEdge,
        rightEdge: this.rightEdge
      };
    },
    onBeforeRender: function(){
      this.leftEdge = (this.model.get('page') < this.pageOffset + 1) ? 1 : this.model.get('page') - this.pageOffset;
      this.rightEdge = (this.model.get('page') + this.pageOffset + 1 > this.model.get('total_pages')) ?
        this.model.get('total_pages') :
        this.model.get('page') + this.pageOffset;
    },
    setPage: function(e){
      this.model.set('page', parseInt($(e.currentTarget).html(),10) );
    },
    prevPage: function(e){
      if (this.model.get('page') > 1)
        this.model.set('page', this.model.get('page') - 1 );
    },
    nextPage: function(e){
      if (this.model.get('page') < this.model.get('total_pages'))
        this.model.set('page', this.model.get('page') + 1 );
    },
    modelChanged: function(model){
      Robin.Newsroom.controller.paginate(this.model.get('page'));
      this.render();
    }
  });
});
