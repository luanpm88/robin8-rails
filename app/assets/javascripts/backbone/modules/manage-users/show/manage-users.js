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
      var viewObj = this;
      
      swal({
        title: polyglot.t("manage_users.messages.remove_user"),
        text: polyglot.t("manage_users.messages.remove_explanation"),
        type: "error",
        showCancelButton: true,
        cancelButtonText: polyglot.t("manage_users.messages.cancel_button"),
        confirmButtonClass: 'btn-danger',
        confirmButtonText: polyglot.t("manage_users.messages.confirm_button")
      },
      function(isConfirm) {
        if (isConfirm) {
          $.ajax({
            type: 'DELETE',
            url: '/users/delete_user',
            dataType: 'json',
            data: r.attributes,
            success: function(data, textStatus, jqXHR) {
              Robin.user.fetch({
                success: function(){
                  if (Robin.user.get('can_create_seat') != true) {
                    $("button.invite").addClass('disabled-unavailable');
                  } else {
                    $("button.invite").removeClass('disabled-unavailable');
                  }
                }
              });
              r.collection.fetch();
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

    onRender: function(){
      var curView = this;
      Robin.user = new Robin.Models.User()
      Robin.user.fetch({
        success: function(){
          if (Robin.user.get('can_create_seat') != true) {
            curView.$el.find("button.invite").addClass('disabled-unavailable');
          } else {
            curView.$el.find("button.invite").removeClass('disabled-unavailable');
          }
        }
      })
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
                transformer: function($field, validatorName, validator) {
                  var s = $field.val();
                  if (s.indexOf(" ") > -1) {
                    $field.val($field.val().trim());
                  }
                  var value = $field.val();
                  return value;
                },
                regexp: /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/,
                message: polyglot.t("manage_users.messages.invalid_data")
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
        $('#invite-form').formValidation('validateField', 'email')
      })
    },

    filterUsers: function() {
      if (this.collection.length > 0) {
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
      }
    },

    sendInvite: function(e){
      if (Robin.user.get('can_create_seat') != true) {
        $.growl({message: polyglot.t("manage_users.messages.not_available_seats")},
          {
            type: 'info'
          });
      } else {
        var viewObj = this;
        e.preventDefault();
        var email = $("#email").val();
        $('#invite-form').data('formValidation').validate();
        if ($('#invite-form').data('formValidation').isValid()) {
          $.post("/users/invitation.json", {user:{email: email, is_primary: false}})
            .always(function(){
              $(".invite").blur();
            })
            .done(function() {
              viewObj.collection.fetch();
            })
            .fail(function(response) {
              Robin.user.fetch({
                success: function(){
                  if (Robin.user.get('can_create_seat') != true) {
                    viewObj.$el.find("button.invite").addClass('disabled-unavailable');
                  } else {
                    viewObj.$el.find("button.invite").removeClass('disabled-unavailable');
                  }
                }
              })
              if (response.responseText == "active"){
                $.growl(polyglot.t("manage_users.messages.is_active"), {type: "danger"});
              } else if (response.responseText == "sent" || response.responseText == "resent") {
                if (response.responseText == "sent") {
                  $.growl(polyglot.t("manage_users.messages.sent"), {type: "success"});
                } else {
                  $.growl(polyglot.t("manage_users.messages.resent"), {type: "success"});
                };
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
      }
    },

  });
});