$("a.firstname").click(function(event) {
	event.preventDefault();
	$("div.dynamic_content").innerHTML="<p>TEST TEST TEST TEST</p>";
});