require "test_helper"

class FileReverseReaderTest < ActiveSupport::TestCase
  sub_test_case "#each_line" do
    data(
        "small file" => File.size(fixture_path("error0.log")),
        "large file" => 2,
      )
    test "read at once" do |step|
      io = File.open(fixture_path("error0.log"))
      reader = FileReverseReader.new(io, step)
      subject = reader.enum_for(:each_line)
      File.open(fixture_path("error0.log"), "r") do |file|
        assert_equal(file.each_line.count, subject.count)
      end
      File.open(fixture_path("error0.log"), "r") do |file|
        assert_equal(file.each_line.to_a.map(&:strip).reverse, subject.to_a)
      end
      io.close
    end
  end

  data("contain ascii only" => ["ABCDE", false],
       "contain non-ascii" => ["\x89NG", true])
  test "#binary_file?" do |(content, is_binary)|
    File.open(Rails.root + "tmp/log.log", "wb") do |file|
      file.write(content)
    end
    File.open(Rails.root + "tmp/log.log") do |io|
      reader = FileReverseReader.new(io)
      assert_equal(is_binary, reader.binary_file?)
    end
  end

  sub_test_case "#tail" do
    data("2" => [2, "foo\n" * 2],
         "50" => [50, "foo\n" * 50],
         "over log lines" => [100, "foo\n" * 200])
    test "count" do |(count, content)|
      logfile = Rails.root + "tmp/log.log"
      File.open(logfile, "wb") do |file|
        file.write(content)
      end
      File.open(logfile, "r") do |io|
        reader = FileReverseReader.new(io)
        assert_equal(count, reader.tail(count).to_a.size)
      end
    end

    data("compatible with utf-8" => ["utf8あいう\n", ["utf8あいう"]],
         "incompatible with utf-8" => ["eucあいう\n".encode('euc-jp'), []])
    test "non-ascii encoding" do |(content, expected)|
      logfile = Rails.root + "tmp/log.log"
      File.open(logfile, "wb") do |file|
        file.write(content)
      end
      File.open(logfile, "r") do |io|
        reader = FileReverseReader.new(io)
        assert_equal(expected, reader.tail)
      end
    end
  end
end
