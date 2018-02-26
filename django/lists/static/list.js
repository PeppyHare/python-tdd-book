window.Superlists = {}; 
window.Superlists.initialize = function () { 
  $('input[name="text"]').keypress(function () {
  	// if ($(this).value) {
	$('.has-error').hide();
    // }
  });
};