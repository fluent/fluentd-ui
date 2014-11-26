;(function(){
  "use strict";

  $(function(){
    var el = document.querySelector("#vue-setting");
    if(!el) return;

    new Vue({
      el: el,
      data: {
        sections: {
          sources: [],
          matches: []
        }
      },
      created: function() {
        this.update();
      },
      components: {
        section: {
          template: "#vue-setting-section"
        }
      },
      methods: {
        update: function() {
          var self = this;
          $.getJSON("/api/settings", function(data){
            var sources = [];
            var matches = [];
            data.forEach(function(v){
              if(v.name === "source"){
                sources.push(v);
              }else{
                matches.push(v);
              }
            });
            self.sections.sources = sources;
            self.sections.matches = matches;
          });
        }
      }
    });
  });
})();
