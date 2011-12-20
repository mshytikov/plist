#!/usr/bin/env ruby

require 'test/unit'
require 'plist'
require 'stringio'

class RegularObject
  attr_accessor :foo

  def initialize(str)
    @foo = str
  end

  def to_s
    @foo
  end
end

class TestDataElements < Test::Unit::TestCase

  def setup
    @result = Plist.parse_xml( 'test/assets/test_data_elements.plist' )
  end

  def test_regular_object_round_trip
    str = "This object was auto converted"
    expected = RegularObject.new(str)
    actual   = Plist.parse_xml( Plist::Emit.dump(expected, false) )

    assert_equal str, actual
  end

  def test_generator_io_and_file
    expected = <<END
<data>
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==
</data>
END

    expected.chomp!

    fd = IO.sysopen('test/assets/example_data.bin')
    io = IO.open(fd, 'r')

    # File is a subclass of IO, so catching IO in the dispatcher should work for File as well...
    f = File.open('test/assets/example_data.bin')

    assert_equal expected, Plist::Emit.dump(io, false).chomp
    assert_equal expected, Plist::Emit.dump(f, false).chomp

    assert_instance_of StringIO, @result['io']
    assert_instance_of StringIO, @result['file']

    io.rewind
    f.rewind

    assert_equal io.read, @result['io'].read
    assert_equal f.read,  @result['file'].read

    io.close
    f.close
  end

  def test_generator_string_io
    expected = <<END
<data>
dGhpcyBpcyBhIHN0cmluZ2lvIG9iamVjdA==
</data>
END

    sio = StringIO.new('this is a stringio object')

    assert_equal expected.chomp, Plist::Emit.dump(sio, false).chomp

    assert_instance_of StringIO, @result['stringio']

    sio.rewind
    assert_equal sio.read, @result['stringio'].read
  end

  # this functionality is credited to Mat Schaffer,
  # who discovered the plist with the data tag
  # supplied the test data, and provided the parsing code.
  def test_data
    # test reading plist <data> elements
    data = Plist::parse_xml("test/assets/example_data.plist");
    assert_equal( File.open("test/assets/example_data.jpg"){|f| f.read }, data['image'].read )

    # test writing data elements
    expected = File.read("test/assets/example_data.plist")
    result   = data.to_plist
    #File.open('result.plist', 'w') {|f|f.write(result)} # debug
    assert_equal( expected, result )

    # Test changing the <data> object in the plist to a StringIO and writing.
    # This appears extraneous given that plist currently returns a StringIO,
    # so the above writing test also flexes StringIO#to_plist_node.
    # However, the interface promise is to return an IO, not a particular class.
    # plist used to return Tempfiles, which was changed solely for performance reasons.
    data['image'] = StringIO.new( File.read("test/assets/example_data.jpg"))

    assert_equal(expected, data.to_plist )

  end

end
