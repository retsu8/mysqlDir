#!/usr/bin/ruby

require 'rubygems'
require 'pathname'
require 'digest'
require 'facter'
require 'socket'
require 'sequel'
require 'optparse'

def paranoid
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
	scanner
end

def modify
end

def default

end

def scanner
	# Scan directory and add information to array for each file found
	puts "Scanning for directory information"
	Dir.foreach(dir) do |item|
		next if item == '.' or item == ".."
		if checksum == crc32
			Digest::crc32.hexdigest(item)
		else
			Digest::MD5.hexdigest(item)
		end
		items.insert(:name => File.basename(item), 
				:path => File.realpath(item),
				#Gathers information on readablity of file via world readable, returns 3 digit callulation, will be looking for a better return value
				:permission => File.world_readable?(item),
				:ext => File.extname(item),
				:size => File.size(item),
				:hash => checksum,
				:hostname => Socket.gethostname,
				:type => File.ftype(item),
				:updated_at => File.mtime(item),
				:created_at => File.ctime(item))
	end
end


# Grab current directory for scanning
$dir = Pathname.new(Pathname.pwd())
threadCount = Facter.processorcount

#Instanciate variables
$DB = Sequel.sqlite
$userDir = nil
$checksum = md5
$strategy = default

#grab arg values and parse
$options = {}

OptionParser.new do |opts|

	opts.banner = "Usage: -d [dir] -h [md5, crc32], -m [default, update, paranoid]"

	opts.on("-d", "" "") do |d|
		$userDir = d
	end

	opts.on("-h", "md5", "Run md5 hash check") do |h|
		$checksum = "md5"
	end

	opts.on("-h", "crc32", "Run crc32 hash check") do |h|
		$checksum ="crc32"
	end

	opts.on("-m", "update", "Update current sqlite database.") do |m|
		$strategy = "update"
	end

	opts.on("-m", "paranoid", "Rebuild sqlite database.") do |m|
		$strategy = "paranoid"
	end

end.parse!

if userDir != nil 
	dir = userDir
end

if strategy == paranoid
	default
elsif  strategy == update
	modify	
else
	default
end

if DB.all == false
	sqlScanner
end

posts = DB.from(:scanner)

items = DB[:scanner]