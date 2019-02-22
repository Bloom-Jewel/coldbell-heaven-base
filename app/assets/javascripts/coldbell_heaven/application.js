// require jquery
// require jquery_ujs
// require turbolinks

$(document).on('ready turbolinks:load page:load page:restore',function(){
  var el=$('html');el.prop('innerHTML',el.prop('innerHTML').replace(/>\s+</g,'><'));
  $('#page-body .row').each(function(i,x){
    x.classList.remove('row');
    x.classList.add('cbhrow');
  });
});
