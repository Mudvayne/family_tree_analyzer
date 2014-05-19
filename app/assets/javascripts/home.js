$(document).ready(function() {
	
	window.setTimeout(function() {
		$(".alert").slideUp(500);
	}, 5000);

	var enableIfNotEmpty = function() {
		var isEmpty = function(selector) {
			return $(selector).val().trim() === "";
		};
		var areBothFilled = !isEmpty("#file") && !isEmpty("#family-name");
		$("#upload").prop("disabled", !areBothFilled);
	};

	$("#family-name").keyup(enableIfNotEmpty);
	$("#file").change(enableIfNotEmpty);
});