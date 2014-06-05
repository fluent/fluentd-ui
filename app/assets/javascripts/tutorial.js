(function(){
  "use strict";

  // NOTE: should move to common space if this filter used another place
  Vue.filter('to_json', function (value) {
      return JSON.stringify(value);
  })

  $(function(){
    if($('#chapter1').length === 0) return;

    new Vue({
      el: "#chapter1",
      data: {
        "logs": [],
        "payloads": [
          {
            "path": "/debug.foo",
            "data" : {
              "message": "test message", // NOTE: "'" will break curl command
            }
          },
          {
            "path": "/debug.bar",
            "data" : {
              "my_number": 42,
              "my_array": [1, 2, 3]
            }
          },
          {
            "path": "/xxxxx",
            "data" : {
              "xx": "will be unmatched"
            }
          },
          {
            "path": "/slash/convert/to/dot",
            "data" : {
              "greeting": "hello"
            }
          }
        ]
      },

      created: function(){
        this.fetchLogs();
      },

      methods: {
        fetchLogs: function() {
          var self = this;
          new Promise(function(resolve, reject) {
            $.getJSON("/tutorials/log_tail", resolve).fail(reject);
          }).then(function(logs){
            self.logs = logs;
          });
        },
        sendRequest: function(payload){
          new Promise(function(resolve, reject) {
            $.ajax({
              url: "/tutorials/request_fluentd",
              data: JSON.stringify(payload),
              contentType: "application/json",
              dataType: "json",
              type: "POST"
            }).done(resolve).fail(reject);
          })["catch"](function(e){
            console.error(e);
          });
        }
      }
    });
  });
})();
