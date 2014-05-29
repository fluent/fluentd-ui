(function(){
  "use strict";
  var POLLING_INTERVAL = 1 * 1000;

  $(function(){
    var alert = new Vue({
      el: "#alert",
      data: {
        "alerts": []
      },

      created: function(){
        var self = this;
        setInterval(function(){
          self.fetchData().then(function(alerts){
            self.alerts = alerts;
          });
        }, POLLING_INTERVAL);
      },

      computed: {
        hasAlerts: {
          $get: function(){
            return this.alerts.length > 0;
          }
        }
      },

      methods: {
        fetchData: function() {
          // TODO: fetch from Rails app
          return new Promise(function(resolve, reject) {
            resolve([
              {
                "text": "dummy: " + (new Date).toString(),
              },
              {
                "text": "dummy: " + (Math.random()).toString(),
              },
            ]);
          });
        }
      }
    });
  });
})();
