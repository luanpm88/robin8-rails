var wripl = {

    _track: function(user_id, wriplObjectId, eventType, keywords, topics, categories){

        if(this.validInt(user_id) && this.validInt(wriplObjectId) && this.validEventType(eventType)){

            var event = '{"event" : {"wripl_object_id" : ' + wriplObjectId + ','
                        + '"event_type" : "' + eventType + '",'
                        + '"user_id" : ' + user_id + ','
                        + '"topics" : "' + this.validString(topics) + '",'
                        + '"keywords" : "' + this.validString(keywords) + '",' 
                        + '"categories" : "' + this.validString(categories) + '"}}';

            this.postRequest(event);

        }
        
    },

    validEventType: function(eventTypeValue){
        var eventTypes = ["VIEW", "LIKE", "DISLIKE", "SHARE", "INSERT", "INFLUENCE"];
        var eventType = true;
        if(eventTypes.indexOf(eventTypeValue) == -1)
            eventType = false;
        return eventType;
    },

    validString: function(stringValue){
        if((typeof stringValue === "String") || (stringValue == undefined)) {
            return "";
        }else{
            return stringValue;
        }
    },

    validInt: function(intValue){
        var intType = false;
        if((typeof intValue === "number") &&  (Math.floor(intValue) === intValue))  
            intType = true;
        return intType;   
    },

    postRequest: function(actionEvent){
        
        var xhr = this.createRequestObject("POST", "/recommendations/event.json", true);
        xhr.setRequestHeader("Content-Type", "application/json; charset=UTF-8");
        xhr.send(actionEvent);

    },

    createRequestObject: function(action, url, async){

      var xhr = new XMLHttpRequest();
      if ("withCredentials" in xhr) {
        // XHR for Chrome/Firefox/Opera/Safari.
        xhr.open(action, url, async);
      } else if (typeof XDomainRequest != "undefined") {
        // XDomainRequest for IE.
        xhr = new XDomainRequest();
        xhr.open(action, url);
      } else {
        // CORS not supported.
        xhr = null;
      }
      return xhr;

    }
}

