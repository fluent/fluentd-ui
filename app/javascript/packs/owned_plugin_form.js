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
      advancedOptions: []
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
    }
  }
}

export { OwnedPluginForm as default }
