'use strict';
import 'lodash/lodash';
$(document).ready(()=> {
  var $firstSetting = $('.js-nested-column.js-multiple:first');

  if ($firstSetting.length === 0) {
    return;
  }

  var counter = 0;
  $('.js-append', $firstSetting).on('click', function(ev){
    ev.preventDefault();
    var $new = $firstSetting.clone(true);
    counter++;

    var fields = $('input,select,textarea', $new);
    _.each(fields, function(elm){
      elm.name = elm.name.replace("0", counter);
    });
    $('label', $new).each(function(_, label){
      var $label = $(label);
      $label.attr('for', $label.attr('for').replace("0", counter));
    });

    $('.js-remove', $new).show();
    $('.js-append', $new).hide();
    $new.appendTo($firstSetting.parent());
  });

  $('.js-remove').on('click', function(ev){
    ev.preventDefault();
    $(this).closest('.js-nested-column').remove();
  });

  var $allSettings = $('.js-nested-column.js-multiple');
  $('.js-append', $allSettings).hide();
  $('.js-remove', $allSettings).show();
  $('.js-append', $firstSetting).show();
  $('.js-remove', $firstSetting).hide();
});
