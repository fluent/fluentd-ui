(function(){
  "use strict";

  $(function(){
    if($('#fluent-log').length === 0) return;

    new Vue({
      el: "#fluent-log",
      paramAttributes: ["logUrl"],
      data: {
        "autoFetch": false,
        "logs": [],
        "limit": 30
      },

      created: function(){
        this.fetchLogs();

        var self = this;
        var timer;
        this.$watch("autoFetch", function(newValue){
          if(newValue === true) {
            timer = setInterval(function(){
              self.fetchLogs();
              var $log = $(".log", self.$el);
              $log.scrollTop($log[0].scrollHeight);
            }, 3000);
          } else {
            clearInterval(timer);
          }
        });
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

