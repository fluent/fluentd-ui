/* global _ */
"use strict";

import "lodash/lodash";
import ConfigField from "./config_field";

const OwnedPluginForm = {
  template: "#vue-owned-plugin-form",
  components: {
    "config-field": ConfigField
  },
  props: [
    "id",
    "optionsJson",
    "initialPluginName",
    "initialParamsJson",
    "pluginType",
    "pluginLabel"
  ],
  data: () => {
    return {
      pluginName: "",
      options: [],
      initialParams: {},
      commonOptions: [],
      advancedOptions: [],
    };
  },

  computed: {
    token: function() {
      return Rails.csrfToken();
    }
  },

  mounted: function() {
    this.options = JSON.parse(this.optionsJson);
    this.initialParams = JSON.parse(this.initialParamsJson || "{}");
    this.pluginName = this.initialPluginName;
    this.$once("data-loaded", () => {
      this.updateSection();
    });
    this.$emit("data-loaded");
  },

  methods: {
    onChange: function() {
      this.updateSection();
      if (this.pluginType === "parse") {
        this.$emit("change-plugin-name", this.pluginName);
      }
    },

    onChangeFormats: function(data) {
      console.log("ownedPluginForm:onChangeFormats", data);
      this.$emit("change-formats", data);
    },

    updateSection: function() {
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
        this.commonOptions = data.commonOptions;
        this.advancedOptions = data.advancedOptions;
      });
    },

    selectId: function(pluginType) {
      return `setting_${pluginType}_type`;
    },
    selectClass: function(pluginType) {
      return `${pluginType} form-control`;
    },
    selectName: function(pluginType) {
      return `setting[${pluginType}_type]`;
    }
  }
};

export { OwnedPluginForm as default };
