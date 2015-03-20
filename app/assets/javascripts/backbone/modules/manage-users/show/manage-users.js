Robin.module('ManageUsers.Show', function(Show, App, Backbone, Marionette, $, _){

  Show.ManageableUser = Backbone.Marionette.ItemView.extend({
    template: 'modules/manage-users/show/templates/_single',
    tagName: "tr",
    className: "user-list--item",
    model: Robin.Models.ManageableUser,

    events: {
      'click #remove-user': 'removeUser',
    },

    initialize: function() {
      sweetAlertInitialize();
    },

    onShow: function() {
      var letters = $("#user-search").val();
      if (letters.length > 0) {
        var pattern = new RegExp(letters,"gi");
        if (!pattern.test(this.model.attributes.email)) {
          this.$el.hide();
        }
      }
    },

    serializeData : function() {
      window.$thisModel = this.model;
      return {
        email: this.model.get('email')
      };
    },

    removeUser: function(e){
      var r = this.model;
      swal({
        title: "Remove this user?",
        text: "You will not be able to recover this user.",
        type: "error",
        showCancelButton: true,
        confirmButtonClass: 'btn-danger',
        confirmButtonText: 'Delete'
      },
      function(isConfirm) {
        if (isConfirm) {
          $.ajax({
            type: 'DELETE',
            url: '/users/delete_user',
            dataType: 'json',
            data: r.attributes,
            success: function(data, textStatus, jqXHR) {
              r.collection.fetch()
            },
            error: function(jqXHR, textStatus, errorThrown) {
              $.growl(textStatus, {
                type: "danger",
              });
            }
          });
        }
      });
    },

  });

  Show.ManageUsersPage = Backbone.Marionette.CompositeView.extend({

    template: "modules/manage-users/show/templates/list",
    childView: Show.ManageableUser,
    childViewContainer: "table",
    collection: new Robin.Collections.ManageableUsers(),

    events: {
      'click .invite': 'sendInvite',
      'keyup #user-search' : 'filterUsers'
    },

    initialize: function() {
      this.collection.fetch();
    },

    filterUsers: function() {
      var letters = $("#user-search").val();
      var pattern = new RegExp(letters,"gi");
      var viewObj = this;
      this.children.each(function(view){
        if (pattern.test(view.model.attributes.email)) {
          view.$el.show();
        } else {
          view.$el.hide();
        }
      });
    },

    sendInvite: function(e){
      var that = this;
      e.preventDefault();
      var email = $("#email").val()
      $.post("/users/invitation.json", {user:{email: email, is_primary: false}})
        .always(function(){$(".invite").blur();})
        .done(function() {
          that.collection.fetch();
        })
        .fail(function(response) {
          var result = $.parseJSON(response.responseText);
          _(result.errors).each(function(errors,field) {
            $('input[name=' + field + ']').addClass('error');
            _(errors).each(function(error, i) {
              formatted_field = s(field).capitalize().value().replace('_', ' ');
              $.growl(formatted_field + ' ' + error, {
                type: "danger",
              });
            });
        });
      });
    },

  });
});