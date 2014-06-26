(function(){
  "use strict";

  $(function(){
    if($('#in_tail_format').length === 0) return;

    new Vue({
      el: "#in_tail_format",
      paramAttributes: ["formatOptions", "initialSelected", "targetFile", "paramsJson"],
      data: {
        regexp: "",
        grok_str: "",
        previewProcessing: false,
        highlightedLines: null
      },

      created: function(){
        this.formatOptions = JSON.parse(this.formatOptions);
        this.formats = Object.keys(this.formatOptions);
        this.format = this.initialSelected;
        this.params = JSON.parse(this.paramsJson);
        this.grok_str = this.params.setting.grok_str;
        this.regexp = this.params.setting.regexp;
        this.$watch('regexp', function(ev){
          this.previewRegexp();
        });

        var updateGrokPreview = _.debounce(_.bind(this.generateRegexp, this), 256);
        this.$watch('grok_str', updateGrokPreview);
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
            this.highlightedLines = null;
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

        generateRegexp: function() {
          var self = this;
          this.previewProcessing = true;
          new Promise(function(resolve, reject) {
            $.ajax({
              method: "POST",
              url: "/api/grok_to_regexp",
              data: {
                grok_str: self.grok_str
              }
            }).done(resolve).fail(reject);
          }).then(function(regexp){
            self.regexp = regexp;
          }).catch(function(e){
            console.error(e);
          });
        },

        previewRegexp: function(){
          if(!this.regexp) return;
          var self = this;
          this.previewProcessing = true;
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
            self.previewProcessing = false;
          })["catch"](function(error){
            console.error(error);
          });
        }
      }
    });
  });
})();

