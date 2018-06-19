'use strict'

import ParserMultilineForm from './parser_multiline_form'
import ConfigField from './config_field'

const OwnedPluginForm = {
  template: "#vue-owned-plugin-form",
  components: {
    "parser-multiline-form": ParserMultilineForm,
    "config-field": ConfigField
  },
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
      this.$nextTick(() => {
        $("[data-toggle=tooltip]").tooltip("dispose")
        $("[data-toggle=tooltip]").tooltip("enable")
      })
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

    onChangeFormats: function(data) {
      console.log("ownedPluginForm:onChangeFormats", data)
      this.$emit("change-formats", data)
    },

    onChangeParseConfig: function(data) {
      console.log("ownedPluginForm:onChangeParseConfig", data)
      this.expression = data.expression
      this.timeFormat = data.timeFormat
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
                "expression": this.expression,
                "time_format": this.timeFormat
              })
            })
          }
          if (option.name === "time_format") {
            foundTimeFormat = true
            this.timeFormat = option.default
            console.log(this.timeFormat)
            this.unwatchTimeFormat = this.$watch("timeFormat", (newValue, oldValue) => {
              console.log({"watch time_format": newValue})
              this.$emit("change-parse-config", {
                "expression": this.expression,
                "time_format": this.timeFormat
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
