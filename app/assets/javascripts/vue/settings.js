;(function(){
  "use strict";

  $(function(){
    var el = document.querySelector("#vue-setting");
    if(!el) return;

    new Vue({
      el: el,
      data: {
        loaded: false,
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
          template: "#vue-setting-section",
          data: {
            mode: "default",
            processing: false,
            editContent: null
          },
          created: function(){
            this.initialState();
          },
          computed: {
            endpoint: function(){
              return "/api/settings/" + this.id;
            }
          },
          methods: {
            onCancel: function(ev) {
              this.initialState();
            },
            onEdit: function(ev) {
              this.mode = "edit";
            },
            onDelete: function(ev) {
              if(!confirm("really?")) return;
              this.destroy();
            },
            onSubmit: function(ev) {
              this.processing = true;
              var self = this;
              $.ajax({
                url: this.endpoint,
                method: "POST",
                data: {
                  _method: "PATCH",
                  id: this.id,
                  content: this.editContent
                }
              }).then(function(data){
                // NOTE: child VM update doesn't effect to parent VM (at least Vue v0.10)
                self.$data = data;
                self.initialState();
              }).always(function(){
                self.processing = false;
              });
            },
            initialState: function(){
              this.mode = "default";
              this.editContent = this.content;
            },
            destroy: function(){
              var self = this;
              $.ajax({
                url: this.endpoint,
                method: "POST",
                data: {
                  _method: "DELETE",
                  id: this.id
                }
              }).then(function(){
                self.$destroy();
              });
            }
          }
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
            self.loaded = true;
          });
        }
      }
    });
  });
})();
