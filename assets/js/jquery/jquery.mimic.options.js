//=== Options controls for checkboxes, select fields, and multiple choice ===//

// This bit of logic is kind of complicated, so im going to give a little preface as to whats
// going on. 
//
// Certain fields can have a dynamic number of options defined. These fields include checkboxes,
// select boxes, and multiple choice (radio buttons). 
// 
// When an user selects on of these fields to edit the "edit page" is loaded. Once loaded, we can 
// expect a few constants to be true. 
// 		1. There is an <ul> with an id="parameter_options" under the edit form
//		2. Each li (both on the edit form and the field avatars) must have a rel="index number"
//		3. The <ul> or <select> field under the field avatar needs an id="options_for_<%= field.id %>"  


(function($){
	$.fn.mimic = function(options){
		
		var debug = options['debug'] || false;
		
		return $(this).each(function() { 
			
			var self = $(this);
			var field_id = self.attr("rel");
			
			$("a.clone").unbind("click").click(function(){
				clone_option(this);
				$("#needs_save").val("#edit_field_" + field_id);
				return false;
			})
			
			$("a.unclone").unbind("click").click(function(){
				unclone_option(this); 
				$("#needs_save").val("#edit_field_" + field_id);
				return false;
			})
			
			$("input.cloning_parameter").unbind("focus").focus(function(){
				highlight_option_text(this)
			})
			
			$("input.cloning_parameter").unbind("blur").blur(function(){
				unhighlight_option_text(this)
			})
			
			$("input.cloning_parameter").unbind("keyup").keyup(function(){
				replace_option_text(this)
			})
						
			//--- add option logic ---//

			// used for fields with the hard type array, the event is triggered by an onclick event
			// directly from the DOM
			function clone_option(link) {

				// clone the parameter
				var i = self.children("li").size();
				var option_num = (parseInt(i)+1).toString();

				logger("Clone the new options as #" + option_num, debug);
				$new_param = $(link).parent().clone();
				$new_param.attr("rel", i);

				// make the "remove_option" link visible
				// it is turned off for the first option to prevent having zero options
				logger("  - Show the delete icon", debug); 
				$new_param.children("a.unclone").css("visibility","visible");
				
				// remove the meta data hidden fields so we dont create
				// undesirable results. the hidden field is a delete flag for the rails
				// convention accept_nested_attributes. when we save the edit form it will look at all 
				// the dynamic field and create them all at once. the delete hidden field allows us to mark which
				// option choice inputs we want to remove then save that all at once.
				logger("  - Remove the hidden delete field", debug); 
				$new_param.children("input[type=hidden]").remove();
				
				// take the input, set the value, name, id 
				logger("  - Setup the new value and name for the input", debug);
				$input = $new_param.children("input.cloning_parameter")
				$input.val("Option " + option_num);
				$input.attr("name", "field[options_attributes]["+i+"][name]");

				// append and create "mimic" the avatar
				logger("  - Append the cloned parameter to the ul", debug); 
				$new_param.appendTo(self);

				// now mimic
				logger("  - Mimic the clone event to the field avatar", debug); 
				mimic($("#options_for_" + field_id), $input);

				// then focus and select it
				$input.focus();
				$input.select();
				
				self.mimic(options);
			}

			function mimic(options,input) {
				logger("    - Field avatar has an " + options.get(0).tagName, debug);
				switch(options.get(0).tagName) {
					case "UL":
						mimic_ul(options,input);
						break;
					case "SELECT":
						mimic_select(options,input);
						break;
				}

			}

			function mimic_ul(options,input) {
				// every field with options abilities has 1 option set by default
				// lets clone that option 
				$new_option = options.children("li[rel=0]").clone();
				// highlight the text of the newly cloned option and set the value of the option 
				// to the value of the option control in the edit form
				$new_option.children("label").html("<span class='safari_highlight'>" + input.val() +"</span>")
				// set the rel to the next index integer
				logger("    - Set the mimic'd option's index (rel) to " + options.children().size(), debug);
				$new_option.attr("rel", options.children().size());
				$new_option.appendTo(options);
				// deselect all inputs and select the newly cloned one
				options.children("li").children("input").attr("checked",false);
				$new_option.children("input").attr("checked",true);
			}

			function mimic_select(options,input) {
				// every field with options abilities has 1 option set by default
				// lets clone that option
				$new_option = options.children("option[rel=0]").clone();
				// set the value of the new option to the value of the option control 
				// in the edit form
				$new_option.val(input.val());
				$new_option.html(input.val());
				// set the rel to the next index integer 
				logger("    - Set the mimic'd option's index (rel) to " + options.children().size(), debug);
				$new_option.attr("rel", options.children().size()-1);
				$new_option.appendTo(options);
				// select the newly cloned option if its a select field type
				$new_option.attr("selected",true);
			}

			//--- remove option logic ---//

			function unclone_option(link) {
				var index = $(link).parent().attr("rel");
				var options = $("#options_for_" + field_id);
				logger("Un-clone the old option #" + index, debug);

				// recfocus to the previous input when we remove an option
				$(link).parent("li").prev("li").children("input").focus();

				// remove the parameter
				$(link).parent().remove();
				$(link).parent().children("input[type=hidden]").each(function(index, value){
					logger("  - Set the hidden destroy field to true", debug);
					if ($(value).hasClass("destroy")) { $(value).val("true") }
					$(value).appendTo(self)
				})

				// remove the avatar
				logger("  - Un-Mimic the clone event to the field avatar", debug); 
				unmimic(options, index);

				// reindex field options and avatars to match after saving
				// its really important that the option's list and avatar list's index match 
				// for a 1-to-1 mimic behavior 
				reindex(options);
				
				
			}

			function unmimic(options,index) {
				switch(options.get(0).tagName) {
					case "UL":
						unmimic_ul(options,index);
						break;
					case "SELECT":
						unmimic_select(options,index);
						break;
				}	
			}

			function unmimic_ul(options,index) {
				$old_avatar = options.children("li[rel="+index+"]");
				$old_avatar.remove();
			}

			function unmimic_select(options,index) {
				$old_avatar = options.children("option[rel="+index+"]");
				$old_avatar.remove();
			}

			function reindex(options) {
				options.children("option[rel=*]").each(function(index,val) {
					$(val).attr("rel",index);
				})

				self.children("li").each(function(index,val) {
					$(val).attr("rel",index);
				})
			}

			//--- highlight option logic ---//

			function highlight_option_text(textbox) {
				$object = $(textbox);
				var i = $object.parent("li.parameter_option").attr("rel");

				$options_for = $("#options_for_"+ field_id);
				// if we are dealing with a ul option list
				if ($options_for.is("ul")) {
					$options_for.children("li[rel="+i+"]").children("label").html("<span class='safari_highlight'>"+ $object.val() +"</span>");
				// if we are dealing with a select box
				} else if ($options_for.is("select")) {
					$options_for.children("option[rel="+i+"]").attr("selected",true);
				}
			}

			function replace_option_text(textbox,fid) {
				$object = $(textbox);
				var i = $object.parent("li.parameter_option").attr("rel");

				$options_for = $("#options_for_" + field_id)
				// if we are dealing with a ul option list
				if ($options_for.is("ul")) {
					$options_for.children("li[rel="+i+"]").children("label").children("span.safari_highlight").html($object.val())
				// if we are dealing with a select box
				} else if ($options_for.is("select")) {
					$options_for.children("option[rel="+i+"]").html($object.val());
					$options_for.children("option[rel="+i+"]").val($object.val());
				}

			}

			function unhighlight_option_text(textbox) {
				$object = $(textbox);
				var i = $object.parent("li.parameter_option").attr("rel");
				placeholder_text = "Option " + i;

				$options_for = $("#options_for_" + field_id)
				// if we are dealing with a ul option list
				if ($options_for.is("ul")) {
					$selected_option = $options_for.children("li[rel="+i+"]").children("label").children("span.safari_highlight");
					$selected_option.removeClass("safari_highlight")
				// if we are dealing with a select box
				} else if ($options_for.is("select")) {
					$selected_option = $options_for.children("option[rel="+i+"]");
				}

				if ($object.val() == "") {
					if ($options_for.is("select")) { $selected_option.val(placeholder_text) }
					$selected_option.html(placeholder_text)
					$object.val(placeholder_text);
				}

			}
			
			
		});
	};
})(jQuery);
