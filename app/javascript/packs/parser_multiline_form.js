'use strict'
const ParserMultilineForm = {
  template: "#vue-parser-multiline-form",
  props: [
    "pluginType"
  ],

  data: function() {
    return {
      formats: ""
    }
  },

  watch: {
    "formats": function(newValue, oldValue) {
      console.log(`watch formats: ${newValue}`)
      this.$emit("change-formats", newValue)
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
