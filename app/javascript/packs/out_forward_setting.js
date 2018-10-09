"use strict";

import TransportConfig from "./transport_config";
import OwnedPluginForm from "./owned_plugin_form";

window.addEventListener("load", () => {
  new Vue({
    el: "#out-forward-setting",
    components: {
      "transport-config": TransportConfig,
      "owned-plugin-form": OwnedPluginForm,
    }
  });
});
