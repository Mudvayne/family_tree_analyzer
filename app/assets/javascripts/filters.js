$(document).ready(function() {
	var allRadio = $(".filters input[type='radio']");
	var textInputs = $(".filters input[type='text']");
	var checkboxes = $(".filters input[type='checkbox']")
	
	textInputs.keyup(function(input) {
		var checkState = $(this).val().trim() !== "";
		$(this).prevAll().children("input[type='checkbox']").prop("checked", checkState);
		if(checkState) {
			allRadio.prop("checked", false);
		}
	});

	checkboxes.change(function(){
		if($(this).is(":checked")) {
			allRadio.prop("checked", false);
		}
	});

	$(allRadio).change(function() {
		textInputs.val("").keyup();
	});

	// Datatable for modal
	// Setup - add a text input to each footer cell
	$('#persons-preview tfoot th').each( function () {
			var title = $('#persons-preview thead th').eq( $(this).index() ).text();
			$(this).html( '<input type="text" placeholder="Search '+title+'" />' );
	});

	// DataTable
	var table = $('#persons-preview').DataTable();

	// Apply the search
	if(table.length > 0) {
		table.columns().eq( 0 ).each( function ( colIdx ) {
			$('input', table.column( colIdx ).footer() ).on( 'keyup change', function () {
					table.column( colIdx )
								.search( this.value )
								.draw();
			});
		});
	}

	var refreshGui = function() {
			var hasSelected = $("#persons-preview .selected").length > 0;
			var kekuleNumber = $("#select-by-kekule-number").val();
			if(hasSelected) {
				// we got a selected person
				var selectedRow = $("#persons-preview .selected");
				var firstname = selectedRow.children().eq(0).text();
				var lastname = selectedRow.children().eq(1).text();
				var selectionType = $("#select-all-decendents").is(":checked") ? "all descendants"
													: $("#select-all-ancestors").is(":checked")  ? "all ancestors"
																																				: "Kekule " + kekuleNumber;

				$("#relative-filter-name").val(firstname + " " + lastname + " (" + selectionType + ")");
				$("#select-relatives-apply").removeProp("disabled");
				$("#relative-filter-checked").prop("checked", "checked");
				$("#relative-filter-checked-input").val("on");
				$("#relative-person-id").val(selectedRow.data("person-id"));
			} else {
				// no one is selected anymore
				$("#relative-filter-name").val("");
				$("#select-relatives-apply").prop("disabled", "disabled");
				$("#relative-filter-checked").removeProp("checked");
				$("#relative-filter-checked-input").val("off");
				$("#relative-person-id").val("");
			}

			if($("#select-all-decendents").is(":checked")) {
				$("#relative-filter-type").val("descendants");
			} else if($("#select-all-ancestors").is(":checked")) {
				$("#relative-filter-type").val("ancestors");
			} else {
				$("#relative-filter-type").val("kekule");
				$("#relative-kekule-number").val(kekuleNumber);
				$("#select-by-kekule-number").removeProp("disabled");

				// validate selected kekule number
				if(/^[1-9][0-9]*$/.test(kekuleNumber)) {
					
				}
			}

			if($("#select-kekule-relative").is(":not(:checked")) {
				$("#select-by-kekule-number").val("");
				$("#select-by-kekule-number").prop("disabled", "disabled");
			}
	}

	// select a row
	$('#persons-preview tbody').on( 'click', 'tr', function () {
		if ($(this).hasClass('selected')) {
			$(this).removeClass('selected');
		} else {
			table.$('.selected').removeClass('selected');
			$(this).addClass('selected');
		}
		refreshGui();
	});

	$("#select-all-decendents").change(refreshGui);
	$("#select-all-ancestors").change(refreshGui);
	$("#select-kekule-descendent").change(refreshGui);
	$("#select-by-kekule-number").keyup(refreshGui);

	$("#select-relatives-cancel").click(function() {
		table.$('.selected').click(); // click on the selected row to deselect it...
	});
});