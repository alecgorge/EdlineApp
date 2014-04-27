function jquery_cb($) {
	// iframe test
	$iframe = $("iframe#docViewBodyIframe");
	if($iframe.length > 0) {
		return success({
			type: "iframe",
			content: 'https://www.edline.net' + $iframe.attr('src')
		});
	}
	
//	$html = $("#mcs_container");
//	if($html.length > 0) {
//		return success({
//		   type: "html",
//		   content: $html.html()
//		});
//	}

	$calendar = $('.calGroup');
	if($calendar.length > 0) {
		return success({
			type: "calendar",
			isSectioned: true,
			sectionedInformation: $calendar.map(function () {
				if($(this).find('.calDateLabel').text().trim() == "") {
					return null;
				}
				return {
					header: $(this).find('.calDateLabel').text().trim(),
					cells: $(this).find('.calItem a.eventBox').map(function () {
						return {
							key:   $("<div />").html($(this).attr('title')).text(),
							url:   $(this).attr('href')
						};
					}).get()
				};
			}).get()
		});
	}

	$list = $('.navList');
	if($list.length > 0) {
		return success({
			type    : "folder",
			contents: $list.find('.navItem a').map(function () {
				return {
					name: $("<div />").html($(this).attr('title')).text(),
					id  : $(this).attr('href')
				};
			}).get()
		});
	}

	return error("nothing matched!");
}
