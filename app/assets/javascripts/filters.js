$(document).ready(function() {
	var allRadio = $(".filters input[type='radio']");
	var textInputs = $(".filters input[type='text']");
	textInputs.keyup(function(input) {
		var checkState = $(this).val().trim() !== "";
		$(this).prevAll().children("input[type='checkbox']").prop("checked", checkState);
		if(checkState) {
			allRadio.prop("checked", false);
		}
	});

	$(allRadio).change(function() {
		textInputs.val("").keyup();
	});

});