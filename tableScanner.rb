#!/usr/bin/ruby

require 'rubygems'
require 'pathname'
require 'digest'
require 'facter'
require 'socket'
require 'sequel'
require 'optparse'

class Checksum
	def hashType
		return ""
	end
end
class CRC32 < Checksum
	def hashType(h)
		return Digest::crc32.hexdigest(h)
	end
end
class MD5 < Checksum
	def hashType(h)
		return Digest::md5.hexdigest(h)
	end
end

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
end

def modify
end

def default

end

def scanner
	# Scan directory and add information to array for each file found
	puts "Scanning for directory information"
	puts "Hashing in " hash "."
	/ attempint polymorphic hash choice
	hash = Checksum[CRC32.new MD5.new]
	/

	Dir.foreach(dir) do |item|
		next if item == '.' or item == ".."
		items.insert(:name => File.basename(item), 
			:path => File.realpath(item),
			#Gathers information on readablity of file via world readable, returns 3 digit callulation, will be looking for a better return value
			:permission => File.world_readable?(item),
			:ext => File.extname(item),
			:size => File.size(item),
			:hash => hash(item),
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
$hash = Digest::crc32.hexdigest
$strategy = default

#grab arg values and parse
$options = {}

OptionParser.new do |opts|

	opts.banner = "Usage: -d [dir] -h [md5, crc32], -m [default, update, paranoid]"

	opts.on("-d", "" "") do |d|
		$userDir = d
	end

	opts.on("-h", "md5", "Run md5 hash check") do |h|
		$hash = Digest::md5.hexdigest
	end

	opts.on("-h", "crc32", "Run crc32 hash check") do |h|
		$hash = Digest::crc32.hexdigest
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