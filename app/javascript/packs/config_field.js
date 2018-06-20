'use strict'
import 'lodash/lodash'

const ConfigField = {
  template: "#vue-config-field",
  props: [
    "pluginType",
    "option",
    "initialExpression",
    "initialTimeFormat",
  ],

  data: function() {
    return {
      expression: null,
      timeFormat: null
    }
  },

  filters: {
    humanize: function(value) {
      return _.capitalize(value.replace("_", " "))
    }
  },

  mounted: function() {
    if (this.option.name === "expression") {
      this.expression = this.initialExpression
    }
    if (this.option.name === "time_format") {
      this.timeFormat = this.initialTimeFormat
    }
    this.$on("hook:updated", () => {
      this.$nextTick(() => {
        console.log("config-field hook:updated")
        $("[data-toggle=tooltip]").tooltip("dispose")
        $("[data-toggle=tooltip]").tooltip("enable")
      })
    })
  },

  watch: {
    "expression": function(newValue, oldValue) {
      this.$emit("change-parse-config", {
        "expression": this.expression,
        "timeFormat": this.timeFormat
      })
    },
    "timeFormat": function(newValue, oldValue) {
      this.$emit("change-parse-config", {
        "expression": this.expression,
        "timeFormat": this.timeFormat
      })
    }
  },

  methods: {
    inputId: function(pluginType, option) {
      return `setting_${pluginType}_0__${option.name}`
    },
    inputName: function(pluginType, option) {
      return `setting[${pluginType}[0]][${option.name}]`
    },
    checked: function(checked) {
      if (checked === true || checked === "true") {
        return "checked"
      } else {
        return ""
      }
    }
  }
}

export { ConfigField as default }
