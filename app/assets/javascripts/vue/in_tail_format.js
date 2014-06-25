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
        this.$watch('regexp', function(ev){
          this.previewRegexp();
        });
      },

      computed: {
        options: function(){
          return this.formatOptions[this.format];
        },
      },

      methods: {
        highlight: function(target) {
        },

        updateHighlightedLines: function() {
          if(!this.regexpMatches) {
            this.highlightedLines = "";
            return;
          }

          var html = jQuery('<div>');
          jQuery.each(this.regexpMatches, function(_, match){
            var colors = [
              "#ff9", "#cff", "#fcf", "#dfd"
            ];
            var ret = jQuery('<div>').text(match.whole).html(); // escape HTML tags
            jQuery.each(match.matches, function(k, v) {
              var currentColor = colors.shift();
              colors.push(currentColor);
              var newChild = jQuery('<span class="regexp-preview" data-toggle="tooltip" data-placement="top" title="'+k+'">').text(v);
              newChild.attr('style', 'background-color:' + currentColor);
              var outerHtml = newChild.wrap('<div>').parent().html();
              ret = ret.replace(jQuery('<div>').text(v).html(), outerHtml);
            });
            html.append(ret);
            html.append("<br />");
          });
          this.highlightedLines = html.html();
          setTimeout(function(){
            $('#in_tail_format').tooltip({
              selector: "[data-toggle=tooltip]",
              container: "body"
            })
          },0);

        },

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
            self.updateHighlightedLines();
          })["catch"](function(error){
            console.error(error);
          });
        }
      }
    });
  });
})();

