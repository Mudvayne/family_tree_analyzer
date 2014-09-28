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

	// fancy loading indicator
	var opts = {
	  lines: 13, // The number of lines to draw
	  length: 20, // The length of each line
	  width: 5, // The line thickness
	  radius: 30, // The radius of the inner circle
	  corners: 1, // Corner roundness (0..1)
	  rotate: 50, // The rotation offset
	  direction: 1, // 1: clockwise, -1: counterclockwise
	  color: '#000', // #rgb or #rrggbb or array of colors
	  speed: 1, // Rounds per second
	  trail: 60, // Afterglow percentage
	  shadow: false, // Whether to render a shadow
	  hwaccel: false, // Whether to use hardware acceleration
	  className: 'spinner', // The CSS class to assign to the spinner
	  zIndex: 2e9, // The z-index (defaults to 2000000000)
	  top: '50%', // Top position relative to parent
	  left: '50%' // Left position relative to parent
	};
	var target = document.getElementById('loading');
	new Spinner(opts).spin(target);
	$(target).hide();
	$(".show-loading-animation").click(function() {
		$(target).show();
	})
});