(function(){
  "use strict";

  $(function(){
    if($('#fluent-log').length === 0) return;

    new Vue({
      el: "#fluent-log",
      paramAttributes: ["logUrl"],
      data: {
        "logs": [],
      },

      created: function(){
        this.fetchLogs();
      },

      methods: {
        fetchLogs: function() {
          var self = this;
          new Promise(function(resolve, reject) {
            $.getJSON(self.logUrl, resolve).fail(reject);
          }).then(function(logs){
            self.logs = logs;
          });
        },
      }
    });
  });
})();

