Directory Structure scanner that inserts filesystem information into a database that can be analysed.

Requirements: 
 - multithreaded (recursive divide and conquer using X threads where X=num_cpus)
 - use as little memory as possible
 - be resumable (if you kill the process, it can resume from where it left off)
 - track the following information:
    - host, filename, path, type ([f]ile,[d]ir,[s]ymlink,[h]ardlink), permission octets, size in bytes, hash, created_at, updated_at
      - copy the md5 from an existing entry if it has the same name, size, and type to avoid cpu overhead.
      - the "hash" can be any hashing function.  The faster the better, so long as the collision rate is at least as good as md5. In fact, it would be cool for the hash function to be selectable as an arg.
      - keep the data in a single table or in separate tables, up to you. 
      - if a file has changed since the last run, it should not create a new row, but update the existing row with new information (hash, size, etc), and update the updated_at accordingly.
    - any other information deemed relevant
    - Use whatever database  you want (mysql, pgsql, sqlite, etc), and use any database lib you want for the language (Sequel for ruby, etc...)
  - accept the following args:
    - root_dir (string, where to start the search, default ='.')
    - paranoid (bool, always compute the md5 even if the name, size, etc. is the same, default='false')
    - threads (integer, default=num_cpus)
    - order  ("breadth" or "depth", whether the script will walk the filesystem breadth-first or depth-first, default='depth')
    - verbose (bool, output verbose information, default='false')
    - depth (integer, how far the recursive function will descend into the directory, use 0 for no limit, default=0)
  - Upon completion, the script should output the following stats:
    - start time, end time, how long it took to run
    - memory used
    - number of files added
    - number of files updated


Initial script will be in Ruby, follow-on scripts to be written in Python, Elixir, Go, and Clojure.
