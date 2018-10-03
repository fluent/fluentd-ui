/* global _ */
"use strict";
import "lodash/lodash";
window.addEventListener("load", () => {
  new Vue({
    el: "#treeview",
    props: {
      initialPath: {
        default: "/var/log",
        type: String
      }
    },
    data: {
      preview: "",
      path: "",
      paths: []
    },

    computed: {
      selected: function(){
        var self = this;
        return _.find(this.paths, function(path){
          return self.path == path.path;
        });
      },
      selectedIsDir: function() {
        if(!this.selected) return true;
        return this.selected.is_dir;
      },
      currentDirs: function() {
        if(this.path === "/") {
          return ["/"];
        }

        var path = this.path;
        if(this.selected && !this.selected.is_dir) {
          path = path.replace(/\/[^/]+$/, "");
        }
        var root = "/";
        var dirs = [];
        path.split("/").forEach(function(dir) {
          dirs.push(root + dir);
          if(dir) {
            root = root + dir + "/";
          }
        });
        return dirs;
      }
    },

    mounted: function(){
      console.log(this.initialPath);
      this.path = this.initialPath;
      this.fetchTree();
      this.$watch("path", this.fetchTree);
      this.$watch("path", this.fetchPreview);
    },

    methods: {
      isAncestor: function(target) {
        return this.path.indexOf(target) === 0;
      },
      basename: function(path) {
        if (path === "/") return "/";
        return path.match(/[^/]+$/)[0];
      },
      fetchTree: function() {
        var self = this;
        return new Promise(function(resolve, reject) {
          $.getJSON(`${relativeUrlRoot}/api/tree?path=${self.path}`, resolve).fail(reject);
        }).then(function(paths){
          console.log(paths);
          self.paths = paths;
        });
      },
      fetchPreview: function(){
        if(!this.selected) return ;
        var self = this;
        this.preview = "";
        new Promise(function(resolve, reject) {
          $.getJSON(`${relativeUrlRoot}/api/file_preview?file=${self.selected.path}`, resolve).fail(reject);
        }).catch(function(e){
          console.error(e);
        }).then(function(lines){
          self.preview = lines.join("\n");
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
