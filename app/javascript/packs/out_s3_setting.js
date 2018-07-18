'use strict';

import OwnedPluginForm from "./owned_plugin_form";
import AwsCredential from "./aws_credential";

$(document).ready(() => {
  new Vue({
    el: "#out-s3-setting",
    components: {
      "owned-plugin-form": OwnedPluginForm,
      "aws-credential": AwsCredential
    }
  });
});
