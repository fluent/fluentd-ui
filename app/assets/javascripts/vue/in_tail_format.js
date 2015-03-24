(function(){
  "use strict";

  $(function(){
    if($('#in_tail_format').length === 0) return;

    var FormatBundle = Vue.component('format-bundle', {
      inherit: true,
      template: "#format-bundle",
      computed: {
        options: {
          get: function(){
            return this.formatOptions[this.format];
          },
        },
        selectableFormats: {
          get: function() {
            return Object.keys(this.formatOptions);
          }
        }
      }
    });

    new Vue({
      el: "#in_tail_format",
      paramAttributes: ["formatOptionsJson", "initialSelected", "targetFile", "paramsJson"],
      data: {
        previewProcessing: false,
        format: "",
        highlightedLines: null,
      },

      compiled: function(){
        this.$watch('params.setting.regexp', function(){
          this.preview();
        });
        this.$watch('format', function(){
          this.preview();
        });
        this.$set("formatOptions", JSON.parse(this.formatOptionsJson));
        this.format = this.initialSelected;

        // initialize params
        // NOTE: if `params.setting.foo` is undefined, Vue can't binding with v-model="params.setting.foo"
        var params = JSON.parse(this.paramsJson);
        if(!params.setting) {
          params.setting = {};
        }
        _.each(this.formatOptions, function(options){
          _.each(options, function(key){
            if(!params.setting.hasOwnProperty(key)){
              params.setting[key] = "";
            }
          });
        });
        this.$set('params', params);
        this.$emit("data-loaded");
      },

      methods: {
        onKeyup: function(ev){
          var el = ev.target;
          if(el.name.match(/\[format/)){
            this.preview();
          }
        },
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
          if(this.previewAjax) {
            this.previewAjax.abort();
          }
          var self = this;
          new Promise(function(resolve, reject) {
            self.previewAjax = $.ajax({
              method: "POST",
              url: "/api/regexp_preview",
              data: {
                regexp: self.params.setting.regexp,
                time_format: self.params.setting.time_format,
                format: _.isEmpty(self.format) ? "regexp" : self.format,
                params: self.params.setting,
                file: self.targetFile
              }
            }).done(resolve).fail(reject);
          }).then(function(result){
            self.params = _.merge(self.params, result.params);
            self.regexpMatches = result.matches;
            self.updateHighlightedLines();
          })["catch"](function(error){
            if(error.stack) {
              console.error(error.stack);
            }
          });
        },
      }
    });
  });
})();

