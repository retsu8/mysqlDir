#!/usr/bin/ruby

require 'rubygems'
require 'pathname'
require 'digest'
require 'facter'
require 'socket'
require 'sequel'
require 'optparse'
require 'openssl'
require 'ruby-xxHash'

class Checksum
  def hashType(h)
    case hash
      when 'CRC32' 
        return Digest::crc32(h)
      when 'MD5'
        return Digest::md5(h)
      when 'SHA1'
        return OpenSSL::Digest::SHA256(h)
      when 'SHA2'
        return OpenSSL::Digest::SHA384(h)
      when 'SHA3'
        return OpenSSL::Digest::SHA512(h)
      when 'RIPEMD160'
        return OpenSSL::Digest::RIPEMD160(h)
      when 'XXHASH'
        return XXhash.xxh64(h, 98765)
      else
        return Digest::md5(h)
      end
  end
end

def modify
  $items = DB[:dirScanner].order(:name)
  Dir.foreach(dir) do |item|
    next if ['.','..'].include?(item)
    selection = items.where(:path => item)
      if paranoid == true
        $rows = items.where(:size => File.size(item), :path => File.realpath(item), :name => item, :host => File.gethostname, :hash => Checksum.hashtype(File.realpath(items)))
    # i think what you want is something like:
    # if paranoid
    #   
      else
         rows = items.where(:size => File.size(item), :path => File.realpath(item), :name => item, :host => File.gethostname)
      end
      if rows.empty?
          items.insert(:name => File.basename(item), 
            :path => File.realpath(item),
            #Gathers information on readablity of file via world readable, returns 3 digit callulation, will be looking for a better return value
            :permission => File.world_readable?(item),
            :ext => File.extname(item),
            :size => File.size(item),
            :hash => Checksum.hash(item),  # this can't work, so.... it looks 
            :hostname => Socket.gethostname,
            :type => File.ftype(item),
            :updated_at => File.mtime(item),
            :created_at => File.ctime(item)
          )
      else
        update(item)
      end
  end
end

def default
  if DB.all == false #TODO: check to see if the dirScanner table exists
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
  def find_files(dir)
    Dir.foreach(dir) do |f|
      next if ['.','..'].include?(f)
      current_file = dir + f
      if File.directory?(current_file)
        find_files(current_file)
      else
        items.insert(:name => File.basename(item), 
        :path => File.realpath(item),
        #Gathers information on readablity of file via world readable, returns 3 digit callulation, will be looking for a better return value
        :permission => File.world_readable?(item),
        :ext => File.extname(item),
        :size => File.size(item),
        :hash => Checksum.hashType(item),  #recheck to make sure it works
        :hostname => Socket.gethostname,
        :type => File.ftype(item),
        :updated_at => File.mtime(item),
        :created_at => File.ctime(item))
      end
    end
  end
  # Scan directory and add information to array for each file found
  /if verbose == true 
      puts "Scanning for directory information"
  $items = DB[:dirScanner]
    Dir.foreach(dir) do |item|
    	 next if ['.','..'].include?(item)
    	items.insert(:name => File.basename(item), 
    		:path => File.realpath(item),
    		#Gathers information on readablity of file via world readable, returns 3 digit callulation, will be looking for a better return value
    		:permission => File.world_readable?(item),
    		:ext => File.extname(item),
    		:size => File.size(item),
    		:hash => Checksum.hashType(item),  #recheck to make sure it works
    		:hostname => Socket.gethostname,
    		:type => File.ftype(item),
    		:updated_at => File.mtime(item),
    		:created_at => File.ctime(item)
        )
    end/
end
def update(item)
  #line 78 Gathers information on readablity of file via world readable, returns 3 digit callulation, will be looking for a better return value
  # you want something like:
  # item = items.where(criteria....)

  item.update(:name => File.basename(item))
  item.update(:path => File.realpath(item))
  item.update(:permission => File.world_readable?(item))
  item.update(:ext => File.extname(item))
  item.update(:size => File.size(item))
  item.update(:hash => Checksum.hash(item))
  item.update(:hostname => Socket.gethostname)
  item.update(:type => File.ftype(item))
  item.update(:updated_at => File.mtime(item))
  item.update(:created_at => File.ctime(item))	
end


#grab start time
t1 = Time.now

# Grab current directory for scanning
$dir = Pathname.new(Pathname.pwd())
$threadCount = Facter.processorcount

#Instantiate variables
$DB = Sequel.mysql('dirScanner.db')
$userDir = nil
$hash = MD5
$strategy = "default"

#grab arg values and parse
$options = {}

OptionParser.new do |opts|

opts.banner = "Usage: -d [dir] -s [modify] -h [md5, crc32, sha256, sha384, sha512, ripem160, xxhash] -p -v"

  opts.on("-d", ".", "Get the directory from the user") do |d|
    $userDir = d
  end

  opts.on("-s", ".", "Get the directory from the user") do |d|
    $strategy = 'modify'
  end

  opts.on("-h", "md5", "Run md5 hash check") do |h|
    $hash = 'MD5'
  end

  opts.on("-h", "crc32", "Run crc32 hash check") do |h|
    $hash = 'CRC32'
  end

  opts.on("-h", "sha256", "Run crc32 hash check") do |h|
    $hash = 'SHA1'
  end

  opts.on("-h", "sha384", "Run crc32 hash check") do |h|
    $hash = 'SHA2'
  end

  opts.on("-h", "sha512", "Run crc32 hash check") do |h|
    $hash = 'SHA3'
  end

  opts.on("-h", "ripemd160", "Run crc32 hash check") do |h|
	$hash = 'RIPEMD160'
  end

  opts.on("-h", "xxhash", "Run crc32 hash check") do |h|
	$hash = 'XXHASH'
  end

  opts.on("-p", "Rebuild sqlite database.") do |m|
	@options[:paranoid] = true
  end

  opts.on("-v", "--verbose", "verbose mode") do
	 @options[:verbose] = true
  end

end.parse!

#set directory to use.
if userDir != nil 
  dir = userDir
end

#add modify if selected
if strategy == "modify" 
	modify
else 
	default
end

#grab end time
t2 = Time.now
t3 = t2-t1

puts t3.to_i