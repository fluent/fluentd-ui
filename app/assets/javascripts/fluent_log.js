(function(){
  "use strict";

  $(function(){
    if($('#fluent-log').length === 0) return;

    new Vue({
      el: "#fluent-log",
      paramAttributes: ["logUrl"],
      data: {
        "logs": [],
        // limit: 30 (with v-model="limit" on shared/vue/_fluent_log)
      },

      created: function(){
        this.fetchLogs();
      },

      methods: {
        fetchLogs: function() {
          var self = this;
          new Promise(function(resolve, reject) {
            $.getJSON(self.logUrl + "?limit=" + self.limit, resolve).fail(reject);
          }).then(function(logs){
            self.logs = logs;
          });
        },
      }
    });
  });
})();

