function jquery_cb($) {
	return success($('.navSectionBar').map(function () {
		return {
			"header": $(this).text().trim(),
			"cells": $(this).next('.navList').find('a').map(function () {
				$a = $(this);

				if($a.find(".dateBox").text().trim().length == 0) {
					return null;
				}

				return {
					"key": $("<div />").html($a.attr('title')).text(),
					"url": $a.attr('href'),
					"value": $a.find(".dateBox").text().replace(/\s+/g," ").trim()
				};
			}).get()
		}
	}).get());
}
