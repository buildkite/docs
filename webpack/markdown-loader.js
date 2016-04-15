var markdown = require('markdown-it');
var hljs = require('highlight.js');

module.exports = function (source) {
  this.cacheable && this.cacheable();

  var parser = markdown('default', {
    highlight: function (str, lang) {
      if (lang && hljs.getLanguage(lang)) {
	try {
	  return hljs.highlight(lang, str).value;
	} catch (err) {}
      }

      try {
	return hljs.highlightAuto(str).value;
      } catch (err) {}

      return '';
    }
  });

  return parser.render(source);
};
