Backbone.Marionette.Renderer.render = function(template, data) {
  if (template === false)
    return;

  var path;
  path = JST["backbone/" + template];
  if (!path) {
    throw "Template " + template + " not found!";
  }
  return path(data);
};
