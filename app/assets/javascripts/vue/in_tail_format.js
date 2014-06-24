(function(){
  "use strict";

  $(function(){
    if($('#in_tail_format').length === 0) return;

    new Vue({
      el: "#in_tail_format",
      paramAttributes: ["formatOptions", "initialSelected", "targetFile"],
      data: {
        // v-model: format
        regexp: ""
      },

      created: function(){
        this.formatOptions = JSON.parse(this.formatOptions);
        this.formats = Object.keys(this.formatOptions);
        this.format = this.initialSelected;
        console.log(this);
        this.$watch('regexp', function(ev){
          console.log("watch");
          this.previewRegexp();
        });
      },

      computed: {
        options: function(){
          return this.formatOptions[this.format];
        }
      },

      filters: {
        highlight: function(target, text) {
          console.log(arguments);
          var html = jQuery('<span class="regexp-preview">').text(text).wrap('<div>').parent().html();
          return target.replace(text, html);
        }
      },

      methods: {
        previewRegexp: function(){
          var self = this;
          new Promise(function(resolve, reject) {
            $.ajax({
              method: "POST",
              url: "/api/regexp_preview",
              data: {
                regexp: self.regexp,
                file: self.targetFile
              }
            }).done(resolve).fail(reject);
          }).then(function(matches){
            self.regexpMatches = matches;
            setTimeout(function(){
              $('.regexp-preview').tooltip({
                selector: "[data-toggle=tooltip]",
                container: "body"
              });
            }, 512); // wait for DOM building by Vue
          })["catch"](function(error){
            console.error(error);
          });
        }
      }
    });
  });
})();

