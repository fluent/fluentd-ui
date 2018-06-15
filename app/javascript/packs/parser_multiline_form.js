'use strict'
import 'lodash/lodash'
const ParserMultilineForm = {
  template: "#vue-parser-multiline-form",
  props: [
    "pluginType",
    "commonOptions"
  ],

  data: function() {
    return {
      formatFirstline: "",
      formats: "",
      formatFirstlineDesc: ""
    }
  },

  watch: {
    "formatFirstLine": function(newValue, oldValue) {
      console.log(`watch formatFirstLine: ${newValue}`)
      this.$emit("change-formats", {
        "format_firstline": this.formatFirstline,
        "formats": this.formats
      })
    },
    "formats": function(newValue, oldValue) {
      console.log(`watch formats: ${newValue}`)
      this.$emit("change-formats", {
        "format_firstline": this.formatFirstline,
        "formats": this.formats
      })
    },
    "commonOptions": function(newValue, oldValue) {
      const option = _.find(newValue, (o) => {
        return o.name === "format_firstline"
      })
      this.formatFirstlineDesc = option.desc
    }
  },

  methods: {
    textareaId: function(pluginType) {
      return `setting_${pluginType}_0__formats`
    },
    textareaName: function(pluginType) {
      return `setting[${pluginType}[0]][formats]`
    }
  }
}

export { ParserMultilineForm as default }
