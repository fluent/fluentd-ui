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
