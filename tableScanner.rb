#!/usr/bin/ruby

require 'mysql'
require 'pathname'

# Grab current directory for scanning
puts "Getting current directory"
dir = Pathname.new(Pathname.pwd())

puts "Building new array for data"
arrSql = Array.new() {Array.new(4)}
	
# Scan directory and add information to array for each file found
puts "Scanning for directory information"
Dir.foreach(dir) do |item|
	next if item == '.' or item == ".."
	name =File.realpath(item)
	arrSql.push name
	owner =File.owned?(item)
	arrSql.push owner
	ext = File.extname(item)
	arrSql.push ext
	size = File.size(item)
	arrSql.push size
end
p arrSql
