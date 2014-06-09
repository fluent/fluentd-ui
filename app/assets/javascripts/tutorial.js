(function(){
  "use strict";

  $(function(){
    // At tutorial chapter1, sending request to fluentd

    if($('#chapter1').length === 0) return;

    new Vue({
      el: "#chapter1",
      data: {
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

      methods: {
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
