$(document).on("page:change", function() {
	
	window.setTimeout(function() {
		$(".alert").slideUp(300);
	}, 3500);

	var enableIfNotEmpty = function() {
		var isEmpty = function(selector) {
			return $(selector).val().trim() === "";
		};
		var isOneEmpty = isEmpty("#file") || isEmpty("#family-name");

		console.log("#file", isEmpty("#file"))
		console.log("#family-name", isEmpty("#family-name"))
		console.log("isOneEmpty / disabled", isOneEmpty)

		$("#upload").prop("disabled", isOneEmpty);
	};

	$("#family-name").keyup(enableIfNotEmpty);
	$("#file").change(enableIfNotEmpty);
});
