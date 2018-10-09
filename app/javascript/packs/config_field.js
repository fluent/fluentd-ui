/* global _ */
"use strict";
import "lodash/lodash";
import store from "./store";

const ConfigField = {
  template: "#vue-config-field",
  props: [
    "pluginType",
    "option",
    "initialTextValue",
  ],

  data: function() {
    return {
      selectedValue: null,
      checkboxValue: null,
      textValue: null,
    };
  },

  filters: {
    humanize: function(value) {
      return _.capitalize(value.replace(/_/g, " "));
    }
  },

  mounted: function() {
    if (this.option.type === "enum") {
      this.selectedValue = this.option.default;
    } else if (this.option.type === "bool") {
      this.checkboxValue = this.option.default;
    } else {
      this.textValue = this.initialTextValue || this.option.default;
    }

    if (this.option.name === "message_format") {
      store.commit("parserParams/setMessageFormat", this.selectedValue);
    }
    if (this.option.name === "rfc5424_time_format") {
      store.commit("parserParams/setRfc5424TimeFormat", this.textValue);
    }
    if (this.option.name === "with_priority") {
      store.commit("parserParams/setWithPriority", this.checkboxValue);
    }
    if (this.option.name === "expression") {
      store.commit("parserParams/Expression", this.textValue);
    }
    if (this.option.name === "timeFormat") {
      store.commit("parserParams/timeFormat", this.textValue);
    }
  },

  updated: function() {
    if (this.option.name === "expression") {
      this.expression = this.initialExpression;
    }
    if (this.option.name === "time_format") {
      this.timeFormat = this.initialTimeFormat;
    }
  },

  methods: {
    onChange: function(event) {
      console.log("onChange", this.option.name,  event.target.value);
      if (this.option.name === "message_format") {
        store.dispatch("parserParams/updateMessageFormat", event);
      }
      if (this.option.name === "rfc5424_time_format") {
        store.dispatch("parserParams/updateRfc5424TimeFormat", event);
      }
      if (this.option.name === "with_priority") {
        store.dispatch("parserParams/updateWithPriority", event);
      }
      if (this.option.name === "expression") {
        store.dispatch("parserParams/updateExpression", event);
      }
      if (this.option.name === "timeFormat") {
        store.dispatch("parserParams/updateTimeFormat", event);
      }
      this.$emit("change-parse-config", {});
    },
    inputId: function(pluginType, option) {
      if (pluginType === "output") {
        return `setting_${option.name}`;
      } else {
        return `setting_${_.snakeCase(pluginType)}_0__${option.name}`;
      }
    },
    inputName: function(pluginType, option) {
      if (pluginType === "output") {
        return `setting[${option.name}]`;
      } else {
        return `setting[${_.snakeCase(pluginType)}[0]][${option.name}]`;
      }
    },
    checked: function(checked) {
      if (checked === true || checked === "true") {
        return "checked";
      } else {
        return "";
      }
    }
  }
};

export { ConfigField as default };
