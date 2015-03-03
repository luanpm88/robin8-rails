// grabbed from here: http://www.joezimjs.com/javascript/using-marionette-to-display-modal-views/

var ModalRegion = Marionette.Region.extend({
  el: "#modal",
  constructor: function() {
    Marionette.Region.prototype.constructor.apply(this, arguments);

//    this.ensureEl();
    this.$el.on('hide.bs.modal', {region:this}, function(event) {
      event.data.region.close();
    });
  },
  
  getDefaultOptions: function(options) {
    if (options == null) {
      options = {};
    }
    return _.defaults(options, {
      title: "default title",
      dialogClass: options.className
    });
  },

  onShow: function() {
    this.$el.modal('show');
  },

  onClose: function() {
    this.$el.modal('hide');
  }
});
