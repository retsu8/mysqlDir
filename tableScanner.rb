#!/usr/bin/ruby

require 'rubygems'
require 'pathname'
require 'digest'
require 'facter'
require 'socket'
require 'sequel'

# Grab current directory for scanning
puts "Getting current directory"
dir = Pathname.new(Pathname.pwd())
threadCount = Facter.processorcount

#create new Mysql instance and use username and password if non found
DB = Sequel.sqlite

posts = DB.from(:scanner)

DB.create_table :scanner do
	primary_key :id
	String :name
	String :path
	String :permission
	String :ext
	Int :size
	String :hash
	String :hostname
	String :type
	String :updated_at
	String :created_at
end

items = DB[:scanner]

# Scan directory and add information to array for each file found
puts "Scanning for directory information"
Dir.foreach(dir) do |item|
	next if item == '.' or item == ".."
	items.insert(:name => File.basename(item), 
				:path => File.realpath(item),
				#Gathers information on readablity of file via world readable, returns 3 digit callulation, will be looking for a better return value
				:permission => File.world_readable?(item)
				:ext => File.extname(item)
				:size => File.size(item)
				:hash => Digest::MD5.hexdigest(item)
				:hostname => Socket.gethostname
				:type => File.ftype(item)
				:updated_at => File.mtime(item)
				:created_at => File.ctime(item)
end