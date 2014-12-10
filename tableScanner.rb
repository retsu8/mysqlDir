#!/usr/bin/ruby

require 'mysql'

begin
	con = Mysql.new 'localhost','user1','enter'
	puts con.get_server_info
	rs = con.query 'SELECT VERSION()'
	puts rs.fetch_row
	
rescue Mysql::Error => e
	puts e.error
	puts e.errno

dir = Dir.pwd
Dir.foreach(dir) do |scan|
	next if item == '.' or item == ".."
	name =File.realpath(scan)
	con.push(name)
	owner =File.owned?(scan)
	con.push(owner)
	ext = File.extname(scan)
	con.push(ext)
	size = File.size(scan)
	con.push(size)
end

ensure
	con.close if con
end
