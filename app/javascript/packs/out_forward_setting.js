"use strict";

import TransportConfig from "./components/transport_config";
import OwnedPluginForm from "./components/owned_plugin_form";

window.addEventListener("load", () => {
  new Vue({
    el: "#out-forward-setting",
    components: {
      "transport-config": TransportConfig,
      "owned-plugin-form": OwnedPluginForm,
    }
  });
});
