require 'pathname'

# this is depth first recursion,
# if you get it working with your script, 
# try breadth first.
def find_files(dir = Pathname.pwd)
  Dir.foreach(dir) do |f|
    next if ['.','..'].include?(f)
    current_file = dir + f
    if File.directory?(current_file)
      puts current_file
      find_files(current_file)
    else
      puts current_file
    end
  end
end