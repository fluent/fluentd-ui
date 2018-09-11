/* global _ */
"use strict";
import "lodash/lodash";

const GrepPattern = {
  template: "#vue-grep-pattern",
  props: [
    "containerType", // and/or
    "grepType", // regexp/exclude
    "index",
  ],
  data: function() {
    return {
      key: null,
      pattern: null,
    }
  },

  filters: {
    humanize: function(value) {
      return _.capitalize(value.replace(/_/g, " "));
    }
  },

  methods: {
    inputId: function(name, index) {
      return `setting_${this.containerType}_${index}_${this.grepType}_0__${name}`;
    },

    inputName: function(name, index) {
      return `setting[${this.containerType}[${index}]][${this.grepType}[0]][${name}]`;
    }
  }
};

export { GrepPattern as default };
