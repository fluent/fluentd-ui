(function(){
  "use strict";

  $(function(){
    if($('#treeview').length === 0) return;

    new Vue({
      el: "#treeview",
      paramAttributes: [],
      data: {
        preview: "",
        path: "/var/log",
        paths: []
      },

      created: function(){
        this.fetchTree();
        this.$watch("path", this.fetchTree);
        this.$watch("path", this.fetchPreview);
      },

      computed: {
        selected: function(){
          var self = this;
          return _.find(this.paths, function(path){
            return self.path == path.path;
          });
        },
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
        fetchPreview: function(){
          var self = this;
          new Promise(function(resolve, reject) {
            $.getJSON("/api/file_preview?file=" + self.selected.path, resolve).fail(reject);
          }).then(function(lines){
            self.preview = lines.join("\n");
          }).catch(function(e){ console.error(e);});
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

