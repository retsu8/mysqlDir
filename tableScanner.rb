#!/usr/bin/ruby

require 'mysql'
require 'pathname'

dir = Pathname.pwd()
dir = Pathname.new(dir)

print dir
begin
	arrSql = Array.new() {Array.new(4)}
n=0
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

end
