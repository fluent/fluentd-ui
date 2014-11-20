(function(){
  "use strict";
  var POLLING_INTERVAL = 3 * 1000;
  var POLLING_URL = "/polling/alerts";

  $(function(){
    if($('#vue-notification').length === 0) return;

    var alert = new Vue({
      el: "#vue-notification",
      data: {
        "alerts": []
      },

      created: function(){
        var timer;
        var self = this;
        var currentInterval = POLLING_INTERVAL;
        var fetch = function(){
          self.fetchAlertsData().then(function(alerts){
            if(self.alerts.toString() == alerts.toString()) {
              currentInterval *= 1.1;
            } else {
              currentInterval = POLLING_INTERVAL;
            }
            self.alerts = alerts;
            timer = setTimeout(fetch, currentInterval);
          })["catch"](function(xhr){
            if(xhr.status === 401) {
              // signed out
            }
            if(xhr.status === 0) {
              // server unreachable (maybe down)
            }
          });
        };
        window.addEventListener('focus', function(ev){
          currentInterval = POLLING_INTERVAL;
          timer = setTimeout(fetch, currentInterval);
        }, false);
        window.addEventListener('blur', function(ev){
          clearTimeout(timer);
        }, false);
        fetch();
      },

      computed: {
        alertsCount: {
          $get: function(){ return this.alerts.length; }
        },
        hasAlerts: {
          $get: function(){ return this.alertsCount > 0; }
        }
      },

      methods: {
        fetchAlertsData: function() {
          return new Promise(function(resolve, reject) {
            $.getJSON(POLLING_URL, resolve).fail(reject);
          });
        }
      }
    });
  });
})();
