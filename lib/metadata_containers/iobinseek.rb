module BinSeek
  def binseek(bytes, seek_table = nil)
    encoded_bytes = bytes.encode("BINARY")
    encoded_bytes_less_1 = encoded_bytes[0..-2]
    return nil if (self.pos + encoded_bytes.size) > self.size
    if encoded_bytes.size == 1
      ord = encoded_bytes.ord
      byte = self.getbyte until (byte == ord) or self.eof?
      if (byte == ord)
        self.seek(-encoded_bytes.size, IO::SEEK_CUR)
      end
      return 0
    end
    seek_table = self.seek_table(encoded_bytes) if seek_table.nil?
    size_less_1 = encoded_bytes.size - 1
    encoded_bytes_last = encoded_bytes[size_less_1].ord
    size_minus_length = self.size - encoded_bytes.size
    while self.pos <= size_minus_length
      chunk_less_1 = self.read(size_less_1)
      chunk_last = self.getbyte
      if (encoded_bytes_last == chunk_last) && (encoded_bytes_less_1 == chunk_less_1)
        self.seek(-encoded_bytes.size, IO::SEEK_CUR)
        return 0
      end
      delta = seek_table[chunk_last.ord]
      delta = encoded_bytes.size if delta.nil?
      self.seek(delta, IO::SEEK_CUR)
    end
    self.seek(self.size)
  end
  def seek_table(encoded_bytes)
    seek_table = [] 
    size_less_1 = encoded_bytes.size - 1
    size_less_1.times { |n| seek_table[encoded_bytes[n].ord] = -(n + 1) }
    seek_table
  end
end

class IO
  include BinSeek
end
if defined?(StringIO) == 'constant' && StringIO.class == Class
  class StringIO
    include BinSeek
  end
end
