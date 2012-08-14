# the perfect tag http://stackoverflow.com/questions/5487947/regex-perfect-hash-tag-regex

exports.match = 
	tag 	: /(^|\s)#([^\s]+)/g
	group 	: /(^|\s)@([^\s]+)/g
	#link 	: /((http|https|ftp):\/\/[\w?=&.\/-;#~%-]+(?![\w\s?&.\/;#~\%\+"=-]*>))/g
	link	: /\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/g