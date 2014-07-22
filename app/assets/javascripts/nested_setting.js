(function(){
  "use strict";

  $(function(){
    if($('.nested-column.multiple').length === 0) return;

    var $setting = $('.nested-column.multiple:first');
    var counter = 0;

    $('.append', $setting).on('click', function(ev){
      ev.preventDefault();
      var $new = $setting.clone(true);
      var elements = $('.form-control', $new);
      _.each(elements, function(elm){
        elm.name = elm.name.replace("0", ++counter);
      });
      var $close = $(this).clone().text('-');
      $close.on('click', function(){
        $new.remove();
      });
      $(".append", $new).replaceWith($close);
      $new.appendTo($setting.parent());
    });
  });
})();

