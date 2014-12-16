#!/usr/bin/ruby

require 'mysql'
require 'pathname'
require 'digest'

# Grab current directory for scanning
puts "Getting current directory"
dir = Pathname.new(Pathname.pwd())

#create new Mysql instance and use username and password
puts "Building new array for data"
arrSql = Mysql.new 'localhost', 'generalUser', 'enter', 'mydb'

#list found databases
arrSql.list_dbs.each do |db|
	puts db
end

arrSql.query("CREATE TABLE IF NOT EXISTS \
		Scanner(name VARCHAR(25), owner VARCHAR(25), ext VARCHAR(25), size INT PRIMARY KEY AUTO_INCREMENT, hash VARCHAR(25))")

# Scan directory and add information to array for each file found
puts "Scanning for directory information"
Dir.foreach(dir) do |item|
	next if item == '.' or item == ".."
	@name =File.realpath(item)
	arrSql.push name
	@owner =File.owned?(item)
	arrSql.push owner
	@ext = File.extname(item)
	arrSql.push ext
	@size = File.size(item)
	arrSql.push size
	@hash = Digest::MD5.hexdigest(item)
	arrSql.push hash
end
p arrSql
