(function(){
  "use strict";

  $(function(){
    if($('#treeview').length === 0) return;

    new Vue({
      el: "#treeview",
      paramAttributes: [],
      data: {
        path: "/var/log",
        paths: []
      },

      created: function(){
        this.fetchTree();
        this.$watch("path", this.fetchTree);
      },

      computed: {
      },

      methods: {
        fetchTree: function() {
          var self = this;
          new Promise(function(resolve, reject) {
            $.getJSON("/api/tree?path=" + self.path, resolve).fail(reject);
          }).then(function(paths){
            self.paths = paths;
          });
        },

        selectPath: function(path){
          this.path = path;
        },
        isSuffixRequired: function(data){
          return data.is_dir && data.path != "/";
        },
        isSelected: function(path){
          return this.path == path;
        }
      }
    });
  });
})();

