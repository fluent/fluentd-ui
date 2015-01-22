$(function(){
  $('.js-fluentd-config-editor').each(function(_, el){
    CodeMirror.fromTextArea(el, {
      theme: "neo",
      lineNumbers: true,
      viewportMargin: Infinity,
      mode: "fluentd"
    });
  });
});
