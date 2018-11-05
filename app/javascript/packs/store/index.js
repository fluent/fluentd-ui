import Vue from "vue/dist/vue.esm";
import Vuex from "vuex/dist/vuex.esm";
import { createNamespaceHelpers } from "vuex/dist/vuex.esm";
import createLogger from "vuex/dist/logger";

Vue.use(Vuex);

const debug = process.env.NODE_ENV !== "production";

import parserParams from "./modules/parser_params";

const store = new Vuex.Store({
  modules: {
    parserParams,
  },
  strict: debug,
  plugins: debug ? [createLogger()] : []
});

export { store as default };
