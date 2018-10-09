/* global _ */
"use strict";
import "lodash/lodash";

const GrepPattern = {
  template: "#vue-grep-pattern",
  props: [
    "containerType", // and/or
    "grepType", // regexp/exclude
    "index",  // the index of and/or
    "subIndex", // the index of regexp/exclude
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
    add: function(event) {
      this.$emit("add-grep-pattern", this.grepType, this.subIndex);
    },
    remove: function(event) {
      this.$emit("remove-grep-pattern", this.grepType, this.subIndex);
    },
    labelId: function(name, index, subIndex) {
      return `label_${this.inputId(name, index, subIndex)}`;
    },
    inputId: function(name, index, subIndex) {
      return `setting_${this.containerType}_${index}_${this.grepType}_${subIndex}__${name}`;
    },
    inputName: function(name, index, subIndex) {
      return `setting[${this.containerType}[${index}]][${this.grepType}[${subIndex}]][${name}]`;
    }
  }
};

export { GrepPattern as default };
