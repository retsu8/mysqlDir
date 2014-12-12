#python scanner
rootdir = raw_input("Root Dir: ")
for root, subFolders, files in os.walk(rootdir):
    for file in files:
        theFile = os.path.join(root,file)
 No newline at end of file
        theFile = os.path.join(root,file)
		
 No newline at end of file
