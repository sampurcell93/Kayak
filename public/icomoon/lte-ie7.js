/* Load this script using conditional IE comments if you need to support IE 7 and IE 6. */

window.onload = function() {
	function addIcon(el, entity) {
		var html = el.innerHTML;
		el.innerHTML = '<span style="font-family: \'icomoon\'">' + entity + '</span>' + html;
	}
	var icons = {
			'icon-menu' : '&#xe000;',
			'icon-settings' : '&#xe001;',
			'icon-equalizer' : '&#xe002;',
			'icon-code' : '&#xe003;',
			'icon-remove' : '&#xe004;',
			'icon-fighter-jet' : '&#xe005;',
			'icon-food' : '&#xe006;',
			'icon-house' : '&#xe009;',
			'icon-search' : '&#xe014;',
			'icon-star' : '&#xe00a;',
			'icon-star-half' : '&#xe00b;',
			'icon-star-empty' : '&#xe00c;',
			'icon-checkmark' : '&#xe007;',
			'icon-target' : '&#xe008;',
			'icon-share-alt' : '&#xf064;',
			'icon-caret-up' : '&#xf0d8;',
			'icon-caret-down' : '&#xf0d7;'
		},
		els = document.getElementsByTagName('*'),
		i, attr, c, el;
	for (i = 0; ; i += 1) {
		el = els[i];
		if(!el) {
			break;
		}
		attr = el.getAttribute('data-icon');
		if (attr) {
			addIcon(el, attr);
		}
		c = el.className;
		c = c.match(/icon-[^\s'"]+/);
		if (c && icons[c[0]]) {
			addIcon(el, icons[c[0]]);
		}
	}
};