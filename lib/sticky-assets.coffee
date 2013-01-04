assets 			= require 'connect-assets'
path 				= require 'path'
handlebars 	= require 'handlebars'

module.exports = exports = () ->

	# connect-assets: rails 3.1 asset pipeline for nodejs
	connect_assets = assets 
		#servePath: '//d29it9lox1mxd7.cloudfront.net'
		buildDir: 'public'
		src: 'app/assets'
		buildFilenamer: (filename, code) -> parts = filename.split('.'); "#{parts[0]}-#{app.version}.#{parts[1]}"

		# tell snockets how to compile mustache templates
		assets.jsCompilers.mustache =
			namespace: "TEMPLATES"
			match: /\.js$/
			compileSync: (sourcePath, source) ->
				assetName = path.basename(sourcePath, '.mustache')
				compiled = handlebars.precompile(source)

				if assetName.charAt(0) is '_'
					"(function() { Handlebars.registerPartial('#{assetName.substring(1)}', Handlebars.template(#{compiled}	)) })();"
				else
					"(function() { window.#{@namespace} = window.#{@namespace} || {}; window.#{@namespace}['#{assetName}'] = Handlebars.template(#{compiled}); })();"

	return connect_assets