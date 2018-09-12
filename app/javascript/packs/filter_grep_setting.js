/* global _ */
"use strict";
import "lodash/lodash";

import GrepContainer from "./grep_container";

$(document).ready(() => {
  new Vue({
    el: "#filter-grep-setting",
    components: {
      "grep-container": GrepContainer,
    },
    data: function() {
      return {
        containers: {
          and: [true],
          or: [true]
        }
      };
    },
    mounted: function() {
      this.$on("add-grep-container", this.addGrepContainer);
      this.$on("remove-grep-container", this.removeGrepContainer);
    },
    methods: {
      addGrepContainer: function(containerType, index) {
        const found = this.containers[containerType].indexOf(false);
        if (found < 0) {
          this.$set(this.containers[containerType], this.containers[containerType].length, true);
        } else {
          this.$set(this.containers[containerType], found, true);
        }
      },
      removeGrepContainer: function(containerType, index) {
        this.$set(this.containers[containerType], index, false);

      }
    }
  });
});
