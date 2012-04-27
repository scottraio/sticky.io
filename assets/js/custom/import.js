(function($){
	$.fn.importUI = function(options){

		return $(this).each(function() { 
			// nothing will be imported until we enable the field for importing
			$(".import_column").click(function(){
				col = $('#col_' + $(this).attr('rel'));
				if (col.is(':disabled')) {
					col.attr('disabled', false);
				} else {
					col.attr('disabled', true)
				}
			})

			// make the columns selectable for use cases like doing a merge on two columns
			$( "#make_selectable" ).selectable({
				filter:'th',
				// when we start the drag, unbind and kill the context menu
				// this allows the menu to only appear when header columns are selected
				start: function() { $(this).unbind("contextmenu"); $(this).trigger("contextmenu", "kill") },
				// when we stop the drag this is where the magic happens, depending on whether or not we selected
				// any items, or we are selecting an aleady merged column we will build the contextmenu to perform 
				// the merge and unmerge actions
				stop: function() {	
					var items = $(".ui-selected",this);
					// only enable the contextmenu if we selected columns already
					if (items.exists()) {
						// if we are selecting an already merged column show the unmerge action in the menu
						if (items.hasClass("merged")) {
							var options = [
								{'Unmerge':function(menuItem,menu) {
									// loop through each of the selected items
									items.each(function(x,obj){
										// get the id (or index of that column)
										id = $(this).attr("rel");
										// now we want to loop through all the existing hidden fields with the name merged[]
										find_merged(id, function(val,input){
											// remove the style and field when we come accross a th.merged with the rel 
											// equal to a value within the array found in the hidden field merged[]
											// so in other words, remove the style and fields when we find an existing merged field
											$("th.merged[rel="+val+"]").removeClass("merged");
											$("select#col_" + val).show();
											$(".import_column[rel="+val+"]").show();
											$("#import_data_header_" + val).children("select").remove();
											$(input).remove();
										})
									})
								}}
							];
						// if this is a fresh column (meaning no 'merged' class associated or this column is not 
						// apart of a merge) then show the merge action in the menu
						} else {
							var options = [
								{'Merge':function(menuItem,menu) {
									merged = [];
									items.each(function(x,obj){
										// get the id of the current selected th column
										id = $(obj).attr("rel");
										// make it merged
										$(obj).addClass("merged");
										// add it to the array
										merged.push(id)
										// hide the select field
										$("select#col_" + id).hide();
										// and the enabler checkbox
										$(".import_column[rel="+id+"]").hide()
									})
									// show the first select box in the array of merged fields 
									$("select#col_" + merged.min()).show();
									$(".import_column[rel="+merged.min()+"]").show();
									// make it enabled
									$("select#col_" + merged.min()).attr("disabled",false);
									$(".import_column[rel="+merged.min()+"]").attr("checked",true);
									// add the ids to the hidden field for importing
									$("#review_and_import").prepend("<input type='hidden' name='imports[merge][]' value='"+merged.join(",")+"' />")
									// trigger the select box as if it was just changed 
									// IMPORTANT needs to happen after we add these fields into the merged list
									$("select#col_" + merged.min()).trigger("change");
								}}
							];
						}
						// build the menu
						$(this).contextMenu(options,{
							theme:'osx',
							showSpeed: 10,
							hideSpeed: 10,
							showTransition: 'fadeIn',
							hideTransition: 'fadeOut'
						});
					} 
			
				}
			});


			// if the user selects an address field type or any other complex
			// field type, we want to load the field mapper wizard and set the value to match
			$(".field_col").change(function(){
				option = $(this).find(":selected");
				type = option.attr("rel");
				index_id = $(this).attr('id').split("col_")[1];
	
				switch(type) {
					case "address":
						// if we are working with already merged fields do this
						if (is_merged(index_id)) {
							find_merged(index_id, function(val,input){ attach_address_subfields(val) })
						// this field is not apart of a merge do this
						} else {
							attach_address_subfields(index_id)
						}
						break;
					default:
						// if we are working with already merged fields do this
						if (is_merged(index_id)) {
							find_merged(index_id, function(val,input){ remove_subfields(val) })
						// this field is not apart of a merge do this
						} else {
							remove_subfields(index_id)
						}				
				}
			})

			// function to create the subfield select box when address fields 
			// are choosen
			function attach_address_subfields(i) {
				$th_header = $("#import_data_header_" + i);
				// if there is already a select box in the th header 
				// do not add another one. Where this becomes a problem 
				// is if we add another complex field type and we switch between the address
				// field and the other complex field type. You would switch to complex_a from address
				// and the subfields of the address type would remain where we would want the subfields 
				// from complex_a. Be aware.
				if ($th_header.children("select").length == 0) {
					$th_header.append(options["address_subfields"]);
					$select = $th_header.children("select");
					$select.attr("name","imports[fields][]["+i+"][subfield]");
				}
			}

			// function to remove any subfields when anything but certain fields
			// are choosen
			function remove_subfields(i) {
				$("#import_data_header_" + i).children("select").remove();
			}

			// these events are for when the user selects the checkbox it populates
			// the hidden fields. We do it this way b/c the checkboxes are outside the scope of the form
			$("#do_geocode").click(function(){
				if ($(this).is(":checked")) {
					$("#imports_geocode").val("true")
				} else {
					$("#imports_geocode").val("false")
				}
			})

			$("#do_no_dups").click(function(){
				if ($(this).is(":checked")) {
					$("#imports_no_dups").val("true")
				} else {
					$("#imports_no_dups").val("false")
				}
			})
		})
	}
})(jQuery);

// these are what we might consider "Class Methods". We want to be able to call these functions
// on the review page as well (ImportsController::Index).

// finds all the merged fields from any giving index ID
function find_merged(index_id,fn) {
	$("input[name='imports[merge][]']").each(function(i,input){
		// if we find the id (above) inside any of the values of these hidden fields
		if ($(input).val().indexOf(index_id) != -1) {
			// turn the values into an array and loop through it
			$.each($(input).val().split(','), function(ix, val) {
				fn(val,input);
			})
		}
	})
}

function is_merged(index_id) {
	var found = false;
	$("input[name='imports[merge][]']").each(function(i,input){
		// if we find the id (above) inside any of the values of these hidden fields
		if ($(input).val().indexOf(index_id) != -1) {
			found = true;
		}
	})
	return found;
}