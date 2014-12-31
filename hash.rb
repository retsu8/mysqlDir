require 'ruby-xxHash'

if ARGV[0] == nil
  puts 'Nothing to hash'
  exit!
else
  file = ARGV[0]

  if ARGV[1] != nil
    seed = ARGV[1]
  else
    seed = 00000
  end

  puts 'The hash is '
  puts XXhash.xxh32(file, seed)
  
end