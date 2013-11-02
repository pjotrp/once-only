begin
  require "digest" 
  Digest::SHA1.hexdigest('test')
rescue LoadError
  $stderr.print "Using native Ruby SHA1 (slow)\n"
  $ruby_sha1 = true
end

module OnceOnly
    
  module Check
    # filter out all arguments that reflect existing files
    def Check::get_file_list list
      list.map { |arg| get_existing_filename(arg) }.compact
    end

    def Check::check_files_exist list
      list.each { |fn| 
        Check::exit_error("File #{fn} does not exist!") if not File.exist?(fn)
      }
    end

    # filter out all names accoding to filters
    def Check::filter_file_list list, regex
      list.map { |name| ( name =~ /#{regex}/ ? nil : name ) }.compact
    end

    # filter out all names accoding to glob (this is not an efficient
    # implementation, as the glob runs for every listed file!)
    def Check::filter_file_list_glob list, glob
      list.map { |name| ( Dir.glob(glob).index(name) ? nil : name ) }.compact
    end

    # Return a hash of files with their hash type, hash value and check time
    def Check::precalculated_checksums(files)
      precalc = {}
      files.each do | fn |
        dir = File.dirname(fn)
        raise "Precalculated hash file should have .md5 extension!" if fn !~ /\.md5$/
        t = File.mtime(fn)
        File.open(fn).each { |s|
          a = s.split
          checkfn = File.expand_path(a[1],dir)
          precalc[checkfn] = { type: 'MD5', hash: a[0], time: t }
        }
      end
      precalc
    end

    # Calculate the checksums for each file in the list and return a list
    # of array - each row containing the Hash type (MD5), the value and the (relative)
    # file path.
    def Check::calc_file_checksums list, precalc
      list.map { |fn|
        # First see if fn is in the precalculated list
        ffn = File.expand_path(fn)
        print ffn
        if precalc[ffn]  
          rec = precalc[ffn]
          [rec[:type],rec[:hash],ffn]
        else
          ['MD5'] + `/usr/bin/md5sum #{fn}`.split  # <--- FIXME: this needs to be ffn
        end
      }
    end

    def Check::calc_checksum(buf)
      if $ruby_sha1
        Sha1::sha1(buf)
      else
        Digest::SHA1.hexdigest(buf)
      end
    end

    # Create a file name out of the content of checksums
    def Check::make_once_filename checksums, prefix = 'once-only'
      buf = checksums.map { |entry| entry }.join("\n")
      prefix + '-' + calc_checksum(buf) + '.txt'
    end

    def Check::write_file fn, checksums
      File.open(fn,'w') { |f|
        checksums.each { |items| f.print items[0],"\t",items[1],"\t",items[2],"\n" }
      }
    end
   
    # Put quotes around regexs and globs 
    def Check::requote list
      a = [ list[0] ]
      list.each_cons(2) { |pair| a << (['--skip-glob','--skip-regex'].index(pair[0]) ? "'#{pair[1]}'" : pair[1]) }
      a
    end

    # Drop --pbs and optional argument from list
    def Check::drop_pbs_option(list)
      is_part_of_pbs_arg = lambda { |p1, p2|
        (p1 == '--pbs' and p2 =~ /\s+/) or p2 == '--pbs'
      }
      a = [ list[0] ]
      list.each_cons(2) { |pair| a << pair[1] if not is_part_of_pbs_arg.call(pair[0],pair[1])}
      a
    end

    # Drop -d argument from list
    def Check::drop_dir_option(list)
      is_part_of_arg = lambda { |p1, p2|
        (p1 == '-d' or p2 == '-d')
      }
      a = [ list[0] ]
      list.each_cons(2) { |pair| a << pair[1] if not is_part_of_arg.call(pair[0],pair[1])}
      a
    end


protected

    def Check::get_existing_filename arg
      return arg if File.exist?(arg)
      # sometimes arguments are formed as -in=file
      (option,filename) = arg.split(/=/)
      return filename if filename and File.exist?(filename)
      nil
    end

    def Check::exit_error msg, errval=1
      $stderr.print "\nERROR: ",msg
      $stderr.print " (once-only returned error #{errval})!\n"
      exit errval
    end
  end

end
