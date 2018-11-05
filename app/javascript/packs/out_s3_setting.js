"use strict";

import OwnedPluginForm from "./components/owned_plugin_form";
import AwsCredential from "./components/aws_credential";

window.addEventListener("load", () => {
  new Vue({
    el: "#out-s3-setting",
    components: {
      "owned-plugin-form": OwnedPluginForm,
      "aws-credential": AwsCredential
    }
  });
});
