window.Superlists = {}; 
window.Superlists.initialize = function () { 
  $('input[name="text"]').keypress(function () {
	$('.has-error').hide();
  });
};
// List checkboxes
// Check first if any of the task is checked
$('#id_list_table input:checkbox').each(function() {
  checkbox_check(this);
});

// Task check box
$('#id_list_table input:checkbox').change(function() {
  checkbox_update(this);
});

// Update checkbox function
function checkbox_update(el) {
  var itemid;
  itemid = $(el).attr("itemid");
  console.log($(el).attr("itemid"));
  console.log("/lists/itemupdate/".concat(itemid));
  if (!$(el).is(':checked')) {
    $.get('/lists/itemupdate/'.concat(itemid), {state: 'active'}, function(data){
	    $(el).next().css('text-decoration', 'none');
	    $(el).next().css('color', 'black');
    });
  } else {
  	$.get('/lists/itemupdate/'.concat(itemid), {state: 'inactive'}, function(data){
	    $(el).next().css('text-decoration', 'line-through');
	    $(el).next().css('color', '#9e9e9e');
  });
}}

// Check Uncheck function
function checkbox_check(el) {
  if (!$(el).is(':checked')) {
    $(el).next().css('text-decoration', 'none');
    $(el).next().css('color', 'black');
  } else {
    $(el).next().css('text-decoration', 'line-through');
    $(el).next().css('color', '#9e9e9e');
}};