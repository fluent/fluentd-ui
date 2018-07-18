/* global _ */
"use strict";
import "lodash/lodash";
import "popper.js/dist/popper";
import "bootstrap/dist/js/bootstrap";
import OwnedPluginForm from "./owned_plugin_form";

$(document).ready(() => {
  new Vue({
    el: "#in-tail-parse",
    components: {
      "owned-plugin-form": OwnedPluginForm
    },
    props: [
      "path",
      "parseType"
    ],
    data: function() {
      return {
        highlightedLines: null
      };
    },
    computed: {
      token: function() {
        return Rails.csrfToken();
      }
    },
    watch: {
      "parse.expression": function() {
        console.log(`parse.expression: ${this.parse.expression}`);
        this.preview();
      },
      "parse.time_format": function() {
        console.log(`parse.time_format: ${this.parse.time_format}`);
        this.preview();
      },
      "parseType": function() {
        this.preview();
      },
    },
    beforeMount: function() {
      this.path = this.$el.attributes.path.nodeValue;
    },
    mounted: function() {
      this.parse = {};
      this.$on("hook:updated", () => {
        this.$nextTick(() => {
          $("[data-toggle=tooltip]").tooltip("dispose");
          $("[data-toggle=tooltip]").tooltip("enable");
        });
      });
    },
    methods: {
      onChangePluginName: function(name) {
        console.log("#in-tail-parse onChangePluginName", name);
        this.parseType = name;
        this.parse = {}; // clear parser plugin configuration
      },
      onChangeParseConfig: function(data) {
        console.log("#in-tail-parse onChangeParseConfig", data);
        _.merge(this.parse, data);
        this.preview();
      },
      onChangeFormats: function(data) {
        console.log("in_tail_parse:onChangeFormats", data);
        _.merge(this.parse, data);
        this.preview();
      },
      updateHighlightedLines: function(matches) {
        if (!matches) {
          this.highlightedLines = null;
          return;
        }

        let $container = $("<div>");
        _.each(matches, (match) => {
          const colors = ["#ff9", "#cff", "#fcf", "#dfd"];
          const whole = match.whole;
          let html = "";
          let _matches = [];
          let lastPos = 0;

          _.each(match.matches, (m) => {
            let matched = m.matched;
            if (!matched) {
              return;
            }
            // Ignore empty matched with "foobar".match(/foo(.*?)bar/)[1] #=> ""
            if (matched.length === 0) {
              return;
            }
            // rotate color
            let currentColor = colors.shift();
            colors.push(currentColor);

            // create highlighted range HTML
            let $highlighted = $("<span>").text(matched);
            $highlighted.attr({
              "class": "regexp-preview",
              "data-toggle": "tooltip",
              "data-placement": "top",
              "title": m.key,
              "style": "background-color:" + currentColor
            });
            let highlightedHtml = $highlighted.wrap("<div>").parent().html();
            let pos = {
              start: m.pos[0],
              end: m.pos[1]
            };
            if (pos.start > 0) {
              html += _.escape(whole.substring(lastPos, pos.start));
            }
            html += highlightedHtml;
            lastPos = pos.end;
          });
          html += whole.substring(lastPos);

          $container.append(html);
          $container.append("<br>");
        });

        this.highlightedLines = $container.html();
        this.$emit("hook:updated");
      },

      preview: function() {
        console.log("preview!!!!");
        if (this.previewAjax && this.previewAjax.state() === "pending") {
          this.previewAjax.abort();
        }

        this.previewAjax = $.ajax({
          method: "POST",
          url: "/api/regexp_preview",
          headers: {
            "X-CSRF-Token": this.token
          },
          data: {
            parse_type: _.isEmpty(this.parseType) ? "regexp" : this.parseType,
            file: this.path,
            plugin_config: this.parse
          }
        }).then(
          (result) => {
            if (result.matches) {
              this.updateHighlightedLines(result.matches);
            } else {
              console.error(result.error);
              this.previewError = result.error;
            }
          },
          (error) => {
            this.highlightedLines = null;
            // console.error(error.responseText)
            if (error.stack) {
              console.error(error.stack);
            }
          });
      }
    }
  });
});
