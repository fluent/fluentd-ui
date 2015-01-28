Vue.filter('to_json', function (value) {
    return JSON.stringify(value);
})


Vue.directive('config-editor', {
  bind: function(){
    var $parent = this.vm;
    // NOTE: needed delay for waiting CodeMirror setup
    _.delay(function(textarea){
      var cm = codemirrorify(textarea);
      cm.on('change', function(code_mirror){
        // bridge Vue - CodeMirror world
        $parent.editContent = code_mirror.getValue();
      });
    }, 0, this.el);
  }
});
