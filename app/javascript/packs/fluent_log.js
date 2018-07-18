"use strict";
$(document).ready(()=> {
  new Vue({
    el: "#fluent-log",
    props: ["logUrl", "initialAutoReload"],
    data: {
      "autoFetch": false,
      "logs": [],
      "limit": 30,
      "processing": false
    },

    computed: {
      isPresentedLogs: function(){
        return this.logs.length > 0;
      }
    },

    beforeMount: function() {
      this.logUrl = this.$el.attributes.logUrl.nodeValue;
      this.initialAutoReload = this.$el.attributes.initialAutoReload.nodeValue;
    },

    mounted: function(){
      this.fetchLogs();

      var self = this;
      var timer;
      this.$watch("autoFetch", function(newValue){
        if(newValue === true) {
          timer = setInterval(function(){
            self.fetchLogs();
            var $log = $(".log", self.$el);
            $log.scrollTop($log.innerHeight());
          }, 1000);
        } else {
          clearInterval(timer);
        }
      });
      if(this.initialAutoReload) {
        this.autoFetch = true;
      }
    },

    methods: {
      fetchLogs: function() {
        if(this.processing) return;
        this.processing = true;
        var self = this;
        new Promise(function(resolve, reject) {
          $.getJSON(self.logUrl + "?limit=" + self.limit, resolve).fail(reject);
        }).then(function(logs){
          self.logs = logs;
          setTimeout(function(){
            self.processing = false;
          }, 256); // delay to reduce flicking loading icon
        })["catch"](function(_error){
          self.processing = false;
        });
      }
    }
  });
});
