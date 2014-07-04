cluster = require 'cluster'
os = require 'os'

if cluster.isMaster
	os.cpus().forEach -> cluster.fork()
	cluster.on 'exit', -> cluster.fork()
else
	require './http'