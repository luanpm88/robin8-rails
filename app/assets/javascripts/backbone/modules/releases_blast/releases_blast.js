Robin.module("ReleasesBlast", function(ReleasesBlast, Robin, Backbone, Marionette, $, _){

  this.startWithParent = false;

  ReleasesBlast.on("start", function(){
    this.pitchContactsCollection = new Robin.Collections.PitchContacts();
    this.layout = new this.Layout();
    this.controller = new this.Controller();
    this.collection = new Robin.Collections.Releases();
    
    this.router = new this.Router({controller: this.controller});
    
    $('#nav-robin8').parent().addClass('active');
    Backbone.history.loadUrl(Backbone.history.fragment);
  });

  ReleasesBlast.on("stop", function(){
    this.layout.destroy();
    this.controller.destroy();
  });

});
