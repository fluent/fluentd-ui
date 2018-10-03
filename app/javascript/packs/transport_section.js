/* global _ */
"use strict";
import "lodash/lodash";

import ConfigField from "./config_field";

window.addEventListener("load", () => {
  new Vue({
    el: "#transport-section",
    components: {
      "config-field": ConfigField
    },
    filters: {
      toUpper: function(value) {
        return _.toUpper(value);
      }
    },
    props: {
      "transportType": {
        default: "tcp",
        type: String
      }
    },
    data: function() {
      return {
        pluginType: null,
        pluginName: null,
        options: ["tcp", "tls"],
        commonOptions: [],
        advancedOptions: []

      };
    },
    computed: {
      token: function() {
        return Rails.csrfToken();
      }
    },
    beforeMount: function() {
      this.pluginType = this.$el.attributes.pluginType.nodeValue;
      this.pluginName = this.$el.attributes.pluginName.nodeValue;
    },
    mounted: function() {
    },
    methods: {
      onChange: function() {
        console.log(this.pluginType, this.pluginName, this.transportType);
        this.updateSection();
      },

      updateSection: function() {
        if (this.transportType === "tcp") {
          return;
        }
        $.ajax({
          method: "GET",
          url: `${relativeUrlRoot}/api/config_definitions`,
          headers: {
            "X-CSRF-Token": this.token
          },
          data: {
            type: this.pluginType,
            name: this.pluginName
          }
        }).then((data) => {
          this.commonOptions = data.transport.commonOptions;
          this.advancedOptions = data.transport.advancedOptions;
        });
      }
    }
  });
});
