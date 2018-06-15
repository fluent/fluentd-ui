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
    hiddenId: function(pluginType, n) {
      return `setting_${pluginType}_0__format${n}`
    },
    hiddenName: function(pluginType, n) {
      return `setting[${pluginType}[0]][format${n}]`
    },
    textareaId: function(pluginType) {
      return `setting_${pluginType}_0__formats`
    },
    textareaName: function(pluginType) {
      return `setting[${pluginType}[0]][formats]`
    }
  }
}

export { ParserMultilineForm as default }
