function codemirrorify(el) {
  return CodeMirror.fromTextArea(el, {
    theme: "neo",
    lineNumbers: true,
    viewportMargin: Infinity,
    mode: "fluentd"
  });
}

$(function(){
  $('.js-fluentd-config-editor').each(function(_, el){
    codemirrorify(el);
  });
});

Vue.directive('config-editor', {
  bind: function(){
    debugger;
    var $parent = this.vm;
    // NOTE: needed delay for waiting CodeMirror setup
    _.delay(function(textarea){
      var cm = codemirrorify(textarea);
      // textarea.codemirror = cm; // for test, but doesn't work for now (working on Chrome, but Poltergeist not)
      cm.on('change', function(code_mirror){
        // bridge Vue - CodeMirror world
        $parent.editContent = code_mirror.getValue();
      });
    }, 0, this.el);
  }
});
