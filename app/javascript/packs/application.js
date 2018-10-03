/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

console.log("Hello World from Webpacker");

import jQuery from "jquery/dist/jquery";

window.$ = jQuery;
window.jQuery = jQuery;

import Rails from "rails-ujs/lib/assets/compiled/rails-ujs.js";

window.Rails = Rails;
Rails.start();

import "popper.js/dist/popper";
import "bootstrap/dist/js/bootstrap";
import "datatables.net/js/jquery.dataTables";
import "startbootstrap-sb-admin/js/sb-admin";
import "startbootstrap-sb-admin/js/sb-admin-datatables";

import Vue from "vue/dist/vue.esm";
import Vuex from "vuex/dist/vuex.esm";
import BootstrapVue from "bootstrap-vue/dist/bootstrap-vue.esm";

Vue.filter("to_json", function (value) {
  return JSON.stringify(value);
});

window.Vue = Vue;
window.Vuex = Vuex;

import "../stylesheets/application.scss";

window.addEventListener("load", () => {
  $("[data-toggle=tooltip]").tooltip();
});
