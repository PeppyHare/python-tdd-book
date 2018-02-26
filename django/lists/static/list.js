window.Superlists = {}; 
window.Superlists.initialize = function () { 
  $('input[name="text"]').keypress(function () {
  	// if ($(this).value) {
  	console.log("Handler for keypress called")
	$('.has-error').hide();
    // }
  });
};