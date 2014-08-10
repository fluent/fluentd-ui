class FileReverseReader
  attr_reader :io, :step

  def initialize(io, step = 1024 * 1024 * 1)
    @io = io
    @step = step
  end

  def each_line(&block)
    io.seek(0, IO::SEEK_END)
    buf = ""
    loop do
      if reach_start_of_file?
        last_pos = io.pos
        io.seek(0, IO::SEEK_SET)
        buf.insert(0, io.read(last_pos))
        split_each_line(buf, &block)
        break
      end

      io.seek(-1 * step, IO::SEEK_CUR)
      buf.insert(0, io.read(step))
      io.seek(-1 * step, IO::SEEK_CUR)
      next if buf[$/].nil?
      gap = buf.index($/)
      buf.gsub!(/\A.*?\n/, "")
      split_each_line(buf, &block)
      buf = ""
      io.seek(gap, IO::SEEK_CUR)
    end
  end

  def tail(limit = 10)
    enum_for(:each_line).first(limit).reverse
  end

  def binary_file?
    sample = io.read(1024) || ""
    !sample.force_encoding('us-ascii').valid_encoding?
  ensure
    io.rewind
  end

  private

  def split_each_line(buf, &block)
    buf.split($/).reverse.each do |line|
      block.call(line)
    end
  end

  def reach_start_of_file?
    step >= io.pos
  end
end
