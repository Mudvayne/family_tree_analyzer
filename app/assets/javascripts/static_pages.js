$(document).on("page:change", function() {
  $("#gedcom-files-table").DataTable({
    ordering: false,
    pageLength: 5,
    lengthMenu: [5, 10, 25, 50, 100]
  });

  $(".rename-gedcom-file").on("click", function() {
    $("#new-gedcom-file-name").val($(this).data("name"))
    $("#gedcom-file-id").val($(this).data("id"))
    $("#rename-modal").modal();
  });
});