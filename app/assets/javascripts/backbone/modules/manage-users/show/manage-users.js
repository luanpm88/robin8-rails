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
        var name = this.model.attributes.first_name + ' ' + this.model.attributes.last_name;
        var mail = this.model.attributes.email;
        if (!pattern.test(name) && !pattern.test(mail)) {
          this.$el.hide();
        }
      }
    },

    serializeData : function() {
      if (this.model.get('avatar_url')) {
        avatar = this.model.get('avatar_url');
      } else {
        avatar = "http://placehold.it/50x50";
      }

      if (this.model.get('first_name')&&this.model.get('last_name')) {
        name = this.model.get('first_name') + " " + this.model.get('last_name');
      } else {
        name = "";
      }
      window.$thisModel = this.model;
      return {
        email: this.model.get('email'),
        avatar_url: avatar,
        name: name
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

  Show.EmptyListView = Backbone.Marionette.ItemView.extend({
    template: 'modules/manage-users/show/templates/_empty',
    className: "user-list--empty",
  });

  Show.ManageUsersPage = Backbone.Marionette.CompositeView.extend({

    template: "modules/manage-users/show/templates/list",
    childView: Show.ManageableUser,
    emptyView: Show.EmptyListView,
    childViewContainer: "table",
    collection: new Robin.Collections.ManageableUsers(),

    events: {
      'click .invite': 'sendInvite',
      'keyup #user-search' : 'filterUsers'
    },

    initialize: function() {
      this.collection.fetch();
    },

    onShow: function() {
      this.initFormValidation();
    },

    initFormValidation: function(){
      $('#invite-form').formValidation({
        framework: 'bootstrap',
        icon: {
          valid: 'glyphicon glyphicon-ok',
          invalid: 'glyphicon glyphicon-remove',
          validating: 'glyphicon glyphicon-refresh'
        },
        fields: {
          email: {
            enabled: false,
            validators: {
              regexp: {
                regexp: /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/,
                message: 'The data you have entered is not a valid email'
              },
              serverError: {
                message: 'something went wrong'
              }
            }
          }
        }
      })
      .on('keyup', '[name="email"]', function() {
        var notEmpty = $(this).val() != "";
        $('#invite-form').formValidation('enableFieldValidators', 'email', notEmpty)
      })
    },

    filterUsers: function() {
      var letters = $("#user-search").val();
      var pattern = new RegExp(letters,"gi");
      var viewObj = this;
      this.children.each(function(view){
        var name = view.model.attributes.first_name + ' ' + view.model.attributes.last_name;
        var mail = view.model.attributes.email;
        if (pattern.test(name) || pattern.test(mail)) {
          view.$el.show();
        } else {
          view.$el.hide();
        }
      });
    },

    sendInvite: function(e){
      var viewObj = this;
      e.preventDefault();
      var email = $("#email").val();
      $('#invite-form').data('formValidation').validate();
      if ($('#invite-form').data('formValidation').isValid()) {
        $.post("/users/invitation.json", {user:{email: email, is_primary: false}})
          .always(function(){$(".invite").blur();})
          .done(function() {
            viewObj.collection.fetch();
          })
          .fail(function(response) {
            if (response.responseText == "active"){
              $.growl('This user is already active', {type: "danger"});
            } else if (response.responseText == "sent" || response.responseText == "resent") {
              $.growl('The invitation has been ' + response.responseText, {type: "success"});
              viewObj.collection.fetch();
            } else {
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
            }
        });
        $("#email").val('');
      }
    },

  });
});