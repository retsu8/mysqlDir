#!/usr/bin/ruby

require 'rubygems'
require 'mysql'
require 'pathname'
require 'digest'
require 'facter'
require 'socket'

# Grab current directory for scanning
puts "Getting current directory"
dir = Pathname.new(Pathname.pwd())
threadCount = Facter.processorcount

#create new Mysql instance and use username and password
puts "Building new array for data"
arrSql = Mysql.new 'localhost', 'generalUser', 'enter', 'mydb'

#list found databases
arrSql.list_dbs.each do |db|
	puts db
end

arrSql.query("CREATE TABLE IF NOT EXISTS \
		Scanner(name NCHAR(255), 
				path NCHAR(255), 
				owner NCHAR(255), 
				ext NCHAR(255), 
				size INT PRIMARY KEY AUTO_INCREMENT, 
				hash TEXT CHARACTER SET latin1 COLLATE latin1_general_cs,
				hostname NCHAR(255),
				type NCHAR(255),
				updated_at NCHAR(255),
				created_at NCHAR(255))")

# Scan directory and add information to array for each file found
puts "Scanning for directory information"
Dir.foreach(dir) do |item|
	next if item == '.' or item == ".."
	@name =File.basename(item)
	arrSql.queary("INSERT INTO Scanner(name) VALUES(name)")
	@path =File.realpath(item)
	arrSql.queary("INSERT INTO Scanner(path) VALUES(path)")
	@owner =File.owned?(item)
	arrSql.queary("INSERT INTO Scanner(owner) VALUES(owner)")
	@ext = File.extname(item)
	arrSql.queary("INSERT INTO Scanner(ext) VALUES(ext)")
	@size = File.size(item)
	arrSql.queary("INSERT INTO Scanner(size) VALUES(size)")
	@hash = Digest::MD5.hexdigest(item)
	arrSql.queary("INSERT INTO Scanner(hash) VALUES(hash)")
	@hostname = Socket.gethostname
	arrSql.queary("INSERT INTO Scanner(hostname) VALUES(hostname)")
	@type = File.ftype(item)
	arrSql.queary("INSERT INTO Scanner(type) VALUES(type)")
	@updated_at = File.mtime(item)
	arrSql.queary("INSERT INTO Scanner(updated_at) VALUES(updated_at)")
	@created_at = File.ctime(item)
	arrSql.queary("INSERT INTO Scanner(created_at) VALUES(created_at)")

end
p arrSql
