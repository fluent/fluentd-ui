/* global _ */
"use strict";

import "lodash/lodash";
import ConfigField from "./config_field";

const TransportConfig = {
  template: "#vue-transport-config",
  components: {
    "config-field": ConfigField
  },
  props: [
    "pluginType",
    "pluginName"
  ],
  data: function() {
    return {
      transportType: "tcp",
      options: ["tcp", "tls"],
      tlsOptions: []
    };
  },
  computed: {
    token: function() {
      return Rails.csrfToken();
    }
  },
  filters: {
    toUpper: function(value) {
      return _.toUpper(value);
    }
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
        this.tlsOptions = data.tlsOptions;
      });
    }
  }
};

export { TransportConfig as default };
