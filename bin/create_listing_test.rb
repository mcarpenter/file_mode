#!/usr/bin/env ruby

require 'tempfile'

require 'file_mode'

def generate_tests(io, name, file, output_proc)
  io.puts "  def test_#{name}"
  (0o0000..0o7777).each do |mode|
    file.chmod(mode)
    # Some OS won't let you chmod(2) files to strange values (eg 0o1001)
    # and drop bits. Solaris does this silently. AIX chmod(1) returns error
    # 0481-014 "not all requested changes were made" (and returns 1).
    # Either way, it doesn't make sense to test these cases.
    io.puts(output_proc[file.path, mode]) if mode == (file.stat.mode & 0o7777)
  end
  io.puts "  end # test_#{name}"
  io.puts
end

ENV['PATH'] = '/bin:/usr/bin'
os = `uname`.chomp
file = Tempfile.new('file_mode')

File.open(File.join('test', "test_#{os.downcase}_listing.rb"), 'w') do |f|
  f.puts <<-EOF

# #{`uname -a`.chomp}
# #{`date`.chomp}

require 'test/unit'

require 'file_mode'

class Test#{os}Listing < Test::Unit::TestCase #:nodoc:

  EOF

  output_proc = ->(path, mode) do
    %Q{    assert_equal(#{'"%04o", FileMode.listing_to_str("%s")' %
      [mode, `find #{path} -ls`.split[2][1..9]]})}
  end
  generate_tests(f, 'find_listing_to_int', file, output_proc)

  output_proc = ->(path, mode) do
    %Q{    assert_equal(#{'"%04o", FileMode.listing_to_str("%s")' %
      [mode, `ls -l #{path}`.split[0][1..9]]})}
  end
  generate_tests(f, 'ls_listing_to_int', file, output_proc)

  if os == 'Linux'
    output_proc = ->(path, mode) do
      %Q{    assert_equal(#{'"%s", FileMode.int_to_listing(0o%04o)' %
        [`ls -l #{path}`.split[0][1..9], mode]})}
    end
    generate_tests(f, 'int_to_listing', file, output_proc)
  end

  f.puts "end # Test#{os}Listing"
  f.puts

end

