/* global _ */
"use strict";
import "lodash/lodash";
import GrepPattern from "./grep_pattern";

const GrepContainer = {
  template: "#vue-grep-container",
  components: {
    "grep-pattern": GrepPattern
  },
  props: [
    "containerType", // and/or
    "index",
  ],
  filters: {
    humanize: function(value) {
      return _.capitalize(value.replace(/_/g, " "));
    }
  },
  methods: {
    add: function(event) {
      this.$emit("add-grep-container", this.containerType, this.index);
    },
    remove: function(event) {
      this.$emit("remove-grep-container", this.containerType, this.index);
    }
  }
};

export { GrepContainer as default };
