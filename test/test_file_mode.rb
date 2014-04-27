
require 'test/unit'
require 'file_mode'

class TestFileMode < Test::Unit::TestCase #:nodoc:

  class TestClass #:nodoc:

    include FileMode

    attr_accessor :mode

    def initialize(mode)
      @mode = mode
    end

  end # TestClass

  def test_class_methods
    assert(FileMode.setuid?(0o4000))
    assert(FileMode.user_executable?(0o0700))
    assert(!FileMode.user_executable?(0o0600))
  end

  def test_instance_methods
    foo = TestClass.new(0o2755)
    assert(foo.mode == 0o2755)
    assert(foo.user_executable?)
    assert(foo.group_executable?)
    assert(foo.other_executable?)
    assert(foo.user_writable?)
    assert(!foo.group_writable?)
    assert(!foo.other_writable?)
    assert(foo.user_readable?)
    assert(foo.group_readable?)
    assert(foo.other_readable?)
    assert(!foo.setuid?)
    assert(foo.setgid?)
    assert(!foo.sticky?)
  end

end # TestFileMode

