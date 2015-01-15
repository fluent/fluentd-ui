class FileReverseReader
  attr_reader :io, :step

  def initialize(io, step = 1024 * 1024 * 1)
    @io = io
    @step = step
  end

  def each_line(&block)
    #read from the end of file
    io.seek(0, IO::SEEK_END)
    buf = ""
    loop do
      if reach_start_of_file?
        read_rest(buf, &block)
        break
      end

      read_to_buf_by_step(buf)

      #if buffer dose not include multi lines, seek more.
      if buf[$/].nil?
        next
      else
        split_only_whole_lines(buf, &block)
        buf = ""
      end
    end
  end

  def tail(limit = 10)
    enum_for(:each_line).first(limit).reverse
  end

  def binary_file?
    sample = io.read(1024) || ""
    !sample.force_encoding('utf-8').valid_encoding?
  ensure
    io.rewind
  end

  private

  def read_rest(buf, &block)
    last_pos = io.pos
    io.seek(0, IO::SEEK_SET)
    buf.insert(0, io.read(last_pos))
    split_each_line(buf, &block)
  end

  def read_to_buf_by_step(buf)
    #move up file pointer by one step
    io.seek(-1 * step, IO::SEEK_CUR) #point[A]
    #read strings by one step from the pointer, and insert to buffer
    #(on io.read, file pointer returns down to the point before [A])
    buf.insert(0, io.read(step))
    #forword file pointer to [A]
    io.seek(-1 * step, IO::SEEK_CUR)
  end

  def split_only_whole_lines(buf, &block)
    #if budder includes multi lines,
    gap = buf.index($/)
    #cut off first line (*first* line because it's seeking from end of file, and first line may be broken-line)
    buf.gsub!(/\A.*?\n/, "")
    split_each_line(buf, &block)
    #move file pointer to the gap(= the end of *first* line)
    io.seek(gap, IO::SEEK_CUR)
  end

  def split_each_line(buf, &block)
    return unless buf.force_encoding('utf-8').valid_encoding?
    buf.split($/).reverse.each do |line|
      block.call(line)
    end
  end

  def reach_start_of_file?
    step >= io.pos
  end
end
