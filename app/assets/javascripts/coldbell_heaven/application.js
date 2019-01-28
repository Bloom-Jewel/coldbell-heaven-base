// require jquery
// require jquery_ujs
// require turbolinks

$(document).ready(function(){
  var el=$('html');el.prop('innerHTML',el.prop('innerHTML').replace(/>\s+</g,'><'));
  $('#page-body .row').each(function(i,x){
    x.classList.remove('row');
    x.classList.add('cbhrow');
  });
});
