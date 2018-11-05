"use strict";
import "lodash/lodash";
import "popper.js/dist/popper";
import "bootstrap/dist/js/bootstrap";
import OwnedPluginForm from "./components/owned_plugin_form";
import ParserPluginForm from "./components/parser_plugin_form";

window.addEventListener("load", () => {
  new Vue({
    el: "#plugin-setting",
    components: {
      "owned-plugin-form": OwnedPluginForm,
      "parser-plugin-form": ParserPluginForm
    },
    data: () => {
      return {};
    },
    methods: {
    }
  });
});
