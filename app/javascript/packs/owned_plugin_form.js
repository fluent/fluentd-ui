'use strict'
const OwnedPluginForm = {
  template: "#vue-owned-plugin-form",
  props: [
    "id",
    "optionsJson",
    "initialPluginName",
    "pluginType",
    "pluginLabel"
  ],
  data: () => {
    return {
      pluginName: "",
      options: [],
      commonOptions: [],
      advancedOptions: [],
      expression: null,
      timeFormat: null,
      unwatchExpression: null,
      unwatchTimeFormat: null
    }
  },

  computed: {
    token: function() {
      return Rails.csrfToken()
    }
  },

  mounted: function() {
    this.options = JSON.parse(this.optionsJson)
    this.pluginName = this.initialPluginName
    this.$on("hook:updated", () => {
      console.log("hook:updated")
      $("[data-toggle=tooltip]").tooltip("dispose")
      $("[data-toggle=tooltip]").tooltip("enable")
    })
    this.$once("data-loaded", () => {
      this.updateSection()
    })
    this.$emit("data-loaded")
  },

  methods: {
    onChange: function() {
      this.updateSection()
      if (this.pluginType === "parse") {
        this.$emit("change-plugin-name", this.pluginName)
      }
    },

    updateSection: function() {
      $.ajax({
        method: "GET",
        url: "/api/config_definitions",
        headers: {
          'X-CSRF-Token': this.token
        },
        data: {
          type: this.pluginType,
          name: this.pluginName
        }
      }).then((data) => {
        this.commonOptions = data.commonOptions
        let foundExpression = false
        let foundTimeFormat = false
        _.each(this.commonOptions, (option) => {
          if (option.name === "expression") {
            foundExpression = true
            this.expression = option.default
            this.unwatchExpression = this.$watch("expression", (newValue, oldValue) => {
              console.log(newValue)
              this.$emit("change-parse-config", {
                expression: this.expression,
                timeFormat: this.timeFormat
              })
            })
          }
          if (option.name === "time_format") {
            foundTimeFormat = true
            this.timeFormat = option.default
            this.unwatchTimeFormat = this.$watch("timeFormat", (newValue, oldValue) => {
              console.log({"watch time_format": newValue})
              this.$emit("change-parse-config", {
                expression: this.expression,
                timeFormat: this.timeFormat
              })
            })
          }

          if (!foundExpression && this.unwatchExpression) {
            this.expression = null
            this.unwatchExpression()
            this.unwatchExpression = null
          }
          if (!foundTimeFormat && this.unwatchTimeFormat) {
            this.timeFormat = null
            this.unwatchTimeFormat()
            this.unwatchTimeFormat = null
          }
        })
      })
    },

    selectId: function(pluginType) {
      return `setting_${pluginType}_type`
    },
    selectClass: function(pluginType) {
      return `${pluginType} form-control`
    },
    selectName: function(pluginType) {
      return `setting[${pluginType}_type]`
    },
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

export { OwnedPluginForm as default }
