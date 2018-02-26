window.Superlists = {}; 
window.Superlists.initialize = function () { 
  $('input[name="text"]').keypress(function () {
	$('.has-error').hide();
  });
};