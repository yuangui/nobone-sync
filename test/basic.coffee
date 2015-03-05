client = require '../client'
server = require '../server'
kit = require 'nokit'
{ Promise } = kit
kit.require 'colors'

now = Date.now() + ''

modifyPassed = false

conf = {
	local_dir: 'test/local'
	remote_dir: 'test/remote'
	host: '127.0.0.1'
	port: 8345
	password: 'test'
	pattern: ['**']
	polling_interval: 30
	on_change: (type, path, old_path) ->
		if path == 'test/local/b.css'
			if type == 'modify'
				modifyPassed = true

		if path == 'test/local/dir/a.txt'
			setTimeout ->
				s = kit.readFileSync 'test/remote/dir/a.txt', 'utf8'
				if modifyPassed and s == now
					process.exit 0
				else
					kit.err 'Sync does not work!'.red
					process.exit 1
			, 500
}

client conf
server kit._.defaults {
	remote_dir: 'test'
	on_change: ->
		new Promise (r) -> setTimeout r, 1
}, conf

setTimeout ->
	kit.touchSync 'test/local/b.css'
, 400

setTimeout ->
	kit.outputFileSync 'test/local/dir/a.txt', now
, 500

process.on 'exit', ->
	kit.removeSync 'test/local/dir/a.txt'
	kit.removeSync 'test/remote/dir/a.txt'
