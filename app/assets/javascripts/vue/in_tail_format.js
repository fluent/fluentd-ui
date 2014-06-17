(function(){
  "use strict";

  $(function(){
    if($('#in_tail_format').length === 0) return;

    new Vue({
      el: "#in_tail_format",
      paramAttributes: ["formatOptions", "initialSelected"],
      data: {
        // v-model: format
      },

      created: function(){
        this.formatOptions = JSON.parse(this.formatOptions);
        this.formats = Object.keys(this.formatOptions);
        this.format = this.initialSelected;
      },

      computed: {
        options: function(){
          return this.formatOptions[this.format];
        }
      },

      methods: {
      }
    });
  });
})();

