require 'set'
require_relative '../id3'
  
  class ID3v2File < ID3File
    attr_reader :header
    
    def initialize(bytes, io)
      @io = io
      @header = self.class.header_class.new(bytes)
    end
  end
  
  class ID3v2Header
    def initialize(raw_bytes)
      @bytes = raw_bytes
    end
    def identifier
      @bytes[0..2]
    end
    def version
      [@bytes.getbyte(3), @bytes.getbyte(4)]
    end
    def rawflags
      @bytes.getbyte(5)
    end
    
    def flags
      flags = self.rawflags
      bitmap = self.flags_bitmap
      @symbols = Array.new
      7.downto(0) do |i|
        if flags[i] == 1
          symbols << bitmap[i] if bitmap[i] != nil
        end
      end
      @symbols
    end
    def flag?(a_symbol)
      self.flags if @symbols.nil?
      @symbols.include?(a_symbol)
    end
    def size()
      size = @bytes.getbyte(6)
      size = (size << 7) + @bytes.getbyte(7)
      size = (size << 7) + @bytes.getbyte(8)
      size = (size << 7) + @bytes.getbyte(9)
    end
  end
  
  class ID3v2Frame
    
    def initialize(raw_bytes)
      @bytes = raw_bytes
    end
    def identifier
      @bytes[0..2]
    end
  end
  



