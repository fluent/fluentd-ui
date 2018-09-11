"use strict";

import GrepContainer from "./grep_container";

$(document).ready(() => {
  new Vue({
    el: "#filter-grep-setting",
    components: {
      "grep-container": GrepContainer,
    },
    data: function() {
      return {
        index: 0
      };
    },
    mounted: function() {
      this.$on("add-grep-container", this.addGrepContainer);
      this.$on("remove-grep-container", this.removeGrepContainer);
    },
    methods: {
      addGrepContainer: function(containerType, index) {
        this.index += 1;
      },
      removeGrepContainer: function(containerType, index) {
        this.index -= 1;
      }
    }
  });
});
