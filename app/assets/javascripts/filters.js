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
	table.columns().eq( 0 ).each( function ( colIdx ) {
		$('input', table.column( colIdx ).footer() ).on( 'keyup change', function () {
				table.column( colIdx )
							.search( this.value )
							.draw();
		});
	});

	var refreshGui = function() {
			var hasSelected = $("#persons-preview .selected").length > 0;
			var kekuleNumber = $("#select-by-kekule-number").val();
			if(hasSelected) {
				// we got a selected person
				var selectedRow = $("#persons-preview .selected");
				var firstname = selectedRow.children().eq(0).text();
				var lastname = selectedRow.children().eq(1).text();
				var selectionType = $("#select-all-decendents").is(":checked") ? "all" : "kekule " + kekuleNumber;
				$("#descendent-filter-name").val(firstname + " " + lastname + " (" + selectionType + ")");
				$("#select-relatives-apply").removeProp("disabled");
				$("#descendent-filter-checked").prop("checked", "checked");
				$("#descendent-filter-checked-input").val("on");
				$("#descendence-person-id").val(selectedRow.data("person-id"));
			} else {
				// no one is selected anymore
				$("#descendent-filter-name").val("");
				$("#select-relatives-apply").prop("disabled", "disabled");
				$("#descendent-filter-checked").removeProp("checked");
				$("#descendent-filter-checked-input").val("off");
				$("#descendence-person-id").val("");
			}

			if($("#select-all-decendents").is(":checked")) {
				$("#descendence-filter-type").val("all");
				$("#select-by-kekule-number").val("");
				$("#select-by-kekule-number").prop("disabled", "disabled");
			} else {
				$("#descendence-filter-type").val("kekule");
				$("#descendence-kekule-number").val(kekuleNumber);
				$("#select-by-kekule-number").removeProp("disabled");
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
	$("#select-kekule-descendent").change(refreshGui);
	$("#select-by-kekule-number").keyup(refreshGui);

	$("#select-relatives-cancel").click(function() {
		table.$('.selected').click(); // click on the selected row to deselect it...
	});
});