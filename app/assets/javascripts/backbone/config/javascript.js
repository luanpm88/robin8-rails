RegExp.escape = function(s) {
  return s.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
};

var openWindow = function(verb, url, data, target) {
  var form = document.createElement("form");
  form.action = url;
  form.method = verb;
  form.target = target || "_self";
  
  // Setting CSRF TOKEN
  var csrf_param = $('meta[name="csrf-param"]').attr('content');
  var csrf_token = $('meta[name="csrf-token"]').attr('content');
  var input = document.createElement("input");
  input.name = csrf_param;
  input.type = "hidden";
  input.value = csrf_token;
  form.appendChild(input);
  
  if (data) {
    for (var key in data) {
      var input = document.createElement("textarea");
      input.name = key;
      input.value = typeof data[key] === "object" ? JSON.stringify(data[key]) : data[key];
      form.appendChild(input);
    }
  }
  form.style.display = 'none';
  document.body.appendChild(form);
  form.submit();
};
