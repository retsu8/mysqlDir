#!/usr/bin/ruby

require 'rubygems'
require 'pathname'
require 'digest'
require 'facter'
require 'socket'
require 'sequel'
require 'optparse'
require 'openssl'
require 'xxhash'

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

class SHA1 < Checksum
  def hashType(h)
    return OpenSSL::Digest::SHA256.hexdigest(h)
  end
end

class SHA2 < Checksum
  def hashType(h)
    return OpenSSL::Digest::SHA384.hexdigest(h)
  end
end

class SHA3 < Checksum
  def hashType(h)
    return OpenSSL::Digest::SHA512.hexdigest(h)
  end
end

class RIPEMD160 < Checksum
  def hashType(h)
    return OpenSSL::Digest::RIPEMD160.hexdigest(h)
  end
end

class XXHASH < Checksum
  def hashType(h)
    return XXHASH.xxh64(h, 98765)
  end
end

def modify
$items = DB[:dirScanner].order(:name)
Dir.foreach(dir) do |item|
  next if item == '.' or item == ".."
  selection = items.where(:path => item)
  if (File.realpath(item) == items.where(:size => item)) & (File.size(item) == items.where(:size => size)) & (File.gethostname == items.where(:host => File.gethostname))
  else (update)
end

def default
  if DB.all == false
    DB.create_table :dirScanner do
      primary_key :id
      String :name
      String :path
      String :permission
      String :ext
      Int :size
      String :hostname
      String :type
      String :updated_at
      String :created_at
      String :hash
    end
    scanner
  else
    $posts = DB.from(:dirScanner)
    modify
end

end

def scanner
# Scan directory and add information to array for each file found
puts "Scanning for directory information"
$items = DB[:dirScanner]
Dir.foreach(dir) do |item|
	next if item == '.' or item == ".."
	items.insert(:name => File.basename(item), 
		:path => File.realpath(item),
		#Gathers information on readablity of file via world readable, returns 3 digit callulation, will be looking for a better return value
		:permission => File.world_readable?(item),
		:ext => File.extname(item),
		:size => File.size(item),
		:hash => Checksum.hash(item),
		:hostname => Socket.gethostname,
		:type => File.ftype(item),
		:updated_at => File.mtime(item),
		:created_at => File.ctime(item))
	end
end

def update
    #line 78 Gathers information on readablity of file via world readable, returns 3 digit callulation, will be looking for a better return value
    items.update(:name => File.basename(item))
    items.update(:path => File.realpath(item))
    items.update(:permission => File.world_readable?(item))
    items.update(:ext => File.extname(item))
    items.update(:size => File.size(item))
    items.update(:hash => Checksum.hash(item))
    items.update(:hostname => Socket.gethostname)
    items.update(:type => File.ftype(item))
    items.update(:updated_at => File.mtime(item))
    items.update(:created_at => File.ctime(item))	
end


#grab start time
t1 = Time.now

# Grab current directory for scanning
$dir = Pathname.new(Pathname.pwd())
$threadCount = Facter.processorcount

#Instantiate variables
$DB = Sequel.sqlite('dirScanner.db')
$userDir = nil
$hash = MD5
$strategy = "default"

#grab arg values and parse
$options = {}

OptionParser.new do |opts|

opts.banner = "Usage: -d [dir] -h [md5, crc32, sha256, sha384, sha512, ripem160, xxhash], -p [paranoid mode]"

  opts.on("-d", ".", "Get the directory from the user") do |d|
    $userDir = d
  end

  opts.on("-h", "md5", "Run md5 hash check") do |h|
    $hash = MD5
  end

  opts.on("-h", "crc32", "Run crc32 hash check") do |h|
    $hash = CRC32
  end

  opts.on("-h", "sha256", "Run crc32 hash check") do |h|
    $hash = SHA1
  end

  opts.on("-h", "sha384", "Run crc32 hash check") do |h|
    $hash = SHA2
  end

  opts.on("-h", "sha512", "Run crc32 hash check") do |h|
    $hash = SHA3
  end

  opts.on("-h", "ripemd160", "Run crc32 hash check") do |h|
	$hash = RIPEMD160
  end

  opts.on("-h", "xxhash", "Run crc32 hash check") do |h|
	$hash = XXHASH
  end

  opts.on("-p", "Rebuild sqlite database.") do |m|
	$strategy = "paranoid"
  end

  opts.on("-v", "--verbose", "verbose mode") do
	 @options[:verbose] = true
  end

end.parse!

#set directory to use.
if userDir != nil 
dir = userDir
end

#pick strategy to use
if strategy == "paranoid" 
	paranoid
else 
	default

#grab end time
t2 = Time.now
t3 = t2-t1

puts t3.to_i