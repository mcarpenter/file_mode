
# Module for UNIX octal file modes. Classes that mixin this module
# must have a mode attribute that is the integer representation
# of the mode.
module FileMode

  # Class methods. These are both extended into the FileMode
  # class and mixed-in as instance methods on classes that
  # "include FileMode" when the class Fixnum attribute :mode
  # is used in place of the argument of the same name.
  module ClassMethods

    # Return true if the mode is readable by user, false otherwise.
    def user_readable?(mode)
      mode & 00400 == 00400
    end

    # Return true if the mode is readable by group, false otherwise.
    def group_readable?(mode)
      mode & 00040 == 00040
    end

    # Return true if the mode is readable by other, false otherwise.
    def other_readable?(mode)
      mode & 00004 == 00004
    end

    # Return true if the mode is writable by user, false otherwise.
    def user_writable?(mode)
      mode & 00200 == 00200
    end

    # Return true if the mode is writable by group, false otherwise.
    def group_writable?(mode)
      mode & 00020 == 00020
    end

    # Return true if the mode is writable by other, false otherwise.
    def other_writable?(mode)
      mode & 00002 == 00002
    end

    # Return true if the mode is executable by user, false otherwise.
    def user_executable?(mode)
      mode & 00100 == 00100
    end

    # Return true if the mode is executable by group, false otherwise.
    def group_executable?(mode)
      mode & 00010 == 00010
    end

    # Return true if the mode is executable by other, false otherwise.
    def other_executable?(mode)
      mode & 00001 == 00001
    end

    # Return true if mode has the setuid bit set, false otherwise.
    def setuid?(mode)
      mode & 04000 == 04000
    end

    # Return true if mode has the setgid bit set, false otherwise.
    def setgid?(mode)
      mode & 02000 == 02000
    end

    # Return true if mode has the sticky bit set, false otherwise.
    def sticky?(mode)
      mode & 01000 == 01000
    end

  end # ClassMethods

  extend ClassMethods

  # Convert an integer mode to a 4 digit octal string.
  def self.int_to_str(int)
    int.to_s(8).rjust(4, '0')
  end

  # Convert an octal string to an integer.
  def self.str_to_int(str)
    str.to_i(8)
  end

  # Convert a permissions listing string to its integer equivalent.
  def self.listing_to_int(listing)
    int = listing.chars.map do |c|
      # l/L are for mandatory file locking on Solaris.
      %w{ - S T l L }.include?(c) ? 0 : 1
    end.join.to_i(2)
    int += 04000 if %w{ s S }.include?(listing[2]) # setuid
    int += 02000 if %w{ s S l L }.include?(listing[5]) # setgid
    int += 01000 if %w{ t T }.include?(listing[8]) # sticky
    int
  end

  # Convert permissions listing string to a string of its octal representation.
  def self.listing_to_str(listing)
    int_to_str(listing_to_int(listing))
  end

  # Mapping between a single octal digit and its permissions listing.
  OCTAL_DIGIT_TO_LISTING = {
    0 => '---',
    1 => '--x',
    2 => '-w-',
    3 => '-wx',
    4 => 'r--',
    5 => 'r-x',
    6 => 'rw-',
    7 => 'rwx'
  }

  # Convert an integer into its permissions listing string. Listing strings
  # may vary between operating systems (and even between applications on the
  # same operating system). The listing output here matches the ouput from
  # Linux/GNU coreutils ls(1).
  def self.int_to_listing(int)
    perms = [ [6, 00700], [3, 00070], [0, 00007] ].map do |bitshift, mask|
      OCTAL_DIGIT_TO_LISTING[(int & mask) >> bitshift]
    end.join
    if 0 != int & 04000 # setuid
      perms[2] = perms[2] == 'x' ? 's' : 'S'
    end
    if 0 != int & 02000 # setgid
      perms[5] = perms[5] == 'x' ? 's' : 'S'
    end
    if 0 != int & 01000 # sticky
      perms[8] = perms[8] == 'x' ? 't' : 'T'
    end
    perms
  end

  # Convert an octal string into its permissions listing string.
  def self.str_to_listing(str)
    int_to_listing(str.to_i(8))
  end

  # Create instance methods on FileMode that forward to the
  # corresponding class method with an implicit self.mode argument.
  ClassMethods.instance_methods(false).each do |mixin_method|
    define_method(mixin_method) do |*args|
      FileMode.send(mixin_method, *(args.dup.unshift(self.mode)))
    end
  end

end # FileMode

