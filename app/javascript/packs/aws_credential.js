"use strict";

import ConfigField from "./config_field";

const AwsCredential = {
  template: "#vue-aws-credential",
  components: {
    "config-field": ConfigField,
  },
  props: [
    "id",
    "pluginType",
    "pluginName",
  ],
  data: () => {
    return {
      credentialType: null,
      credentialOptions: [],
      options: [
        "simple",
        "assumeRoleCredentials",
        "instanceProfileCredentials",
        "sharedCredentials"
      ]
    };
  },

  computed: {
    token: function() {
      return Rails.csrfToken();
    }
  },

  mounted: function() {

  },

  methods: {
    onChange: function() {
      this.updateSection();
    },

    updateSection: function() {
      $.ajax({
        method: "GET",
        url: "/api/config_definitions",
        headers: {
          "X-CSRF-Token": this.token
        },
        data: {
          type: this.pluginType,
          name: this.pluginName
        }
      }).then((data) => {
        this.credentialOptions = data["awsCredentialOptions"][this.credentialType];
      });
    }
  }
};

export { AwsCredential as default };
