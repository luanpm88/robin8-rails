global.imagePreviewer = function (options) {
  $(options.input).change(function(e) {
    var files = e.target.files;
    if(FileReader && files && files.length) {
      var reader = new FileReader();
      options.reader = reader;
      reader.onload = options.onload();
      reader.readAsDataURL(files[0]);
    }
    else {
      alert("Your browser doesn't support file upload!");
    }
  });
};