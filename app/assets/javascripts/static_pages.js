$(document).on("page:change", function() {
  $("#gedcom-files-table").DataTable({
    ordering: false,
    pageLength: 5,
    lengthMenu: [5, 10, 25, 50, 100]
  });
});