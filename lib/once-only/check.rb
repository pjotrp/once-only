begin
  require "digest" 
  Digest::SHA1.hexdigest('test')
rescue LoadError
  $stderr.print "Using native Ruby SHA1 (slow)\n"
  $ruby_sha1 = true
end

module OnceOnly
    
  module Check
    # filter out all names that are existing files
    def Check::get_file_list list
      list.map { |name| ( File.exist?(name) ? name : nil ) }.compact
    end

    # filter out all names accoding to filters
    def Check::filter_file_list list, regex
      list.map { |name| ( name =~ /#{regex}/ ? nil : name ) }.compact
    end

    # Calculate the checksums for each file in the list
    def Check::calc_file_checksums list
      list.map { |fn|
        ['MD5'] + `/usr/bin/md5sum #{fn}`.split
      }
    end

    def Check::calc_hash(buf)
      if $ruby_sha1
        Sha1::sha1(buf)
      else
        Digest::SHA1.hexdigest(buf)
      end
    end

    # Create a file name out of the content of checksums
    def Check::make_once_filename checksums, prefix = 'once-only'
      buf = checksums.map { |entry| entry }.join("\n")
      prefix + '-' + calc_hash(buf) + '.txt'
    end

    def Check::write_file fn, checksums
      File.open(fn,'w') { |f|
        checksums.each { |items| f.print items[0],"\t",items[1],"\t",items[2],"\n" }
      }
    end
  end

end
