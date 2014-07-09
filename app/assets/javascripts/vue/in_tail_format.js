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
        time_format: "",
        previewProcessing: false,
        highlightedLines: null
      },

      created: function(){
        this.formatOptions = JSON.parse(this.formatOptions);
        this.formats = Object.keys(this.formatOptions);
        this.format = this.initialSelected;
        this.params = JSON.parse(this.paramsJson);
        if(this.params && this.params.setting) {
          this.grok_str = this.params.setting.grok_str;
          this.regexp = this.params.setting.regexp;
        }
        this.$watch('regexp', function(ev){
          this.preview();
        });
        this.$watch('format', function(ev){
          this.preview();
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
        updateHighlightedLines: function() {
          if(!this.regexpMatches) {
            this.highlightedLines = null;
            return;
          }

          var $container = jQuery('<div>');
          _.each(this.regexpMatches, function(match){
            var colors = [
              "#ff9", "#cff", "#fcf", "#dfd"
            ];
            var whole = match.whole;
            var html = "";
            var matches = [];

            var lastPos = 0;
            _.each(match.matches, function(match) {
              var matched = match.matched;
              if(!matched) return;
              if(matched.length === 0) return; // Ignore empty matched with "foobar".match(/foo(.*?)bar/)[1] #=> ""

              // rotated highlight color
              var currentColor = colors.shift();
              colors.push(currentColor);

              // create highlighted range HTML
              var $highlighted = jQuery('<span>').text(matched);
              $highlighted.attr({
                "class": "regexp-preview",
                "data-toggle": "tooltip",
                "data-placement": "top",
                "title": match.key,
                'style': 'background-color:' + currentColor
              });
              var highlightedHtml = $highlighted.wrap('<div>').parent().html();

              var pos = {
                "start": match.pos[0],
                "end": match.pos[1]
              };
              if(pos.start > 0) {
                html += _.escape(whole.substring(lastPos, pos.start));
              }
              html += highlightedHtml;
              lastPos = pos.end;
            });
            html += whole.substring(lastPos);

            $container.append(html);
            $container.append("<br />");
          });

          this.highlightedLines = $container.html();
          setTimeout(function(){
            $('#in_tail_format').tooltip({
              selector: "[data-toggle=tooltip]",
              container: "body"
            })
          },0);
        },

        preview: function(){
          var self = this;
          new Promise(function(resolve, reject) {
            $.ajax({
              method: "POST",
              url: "/api/regexp_preview",
              data: {
                regexp: self.regexp,
                format: self.formatType == "regexp" ? "regexp" : self.format,
                time_format: self.time_format,
                file: self.targetFile
              }
            }).done(resolve).fail(reject);
          }).then(function(result){
            self.time_format = result.time_format;
            self.regexpMatches = result.matches;
            self.updateHighlightedLines();
          })["catch"](function(error){
            console.error(error.stack);
          });
        },

        generateRegexp: function() {
          // for grok
          var self = this;
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
      }
    });
  });
})();

