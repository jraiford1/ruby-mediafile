require 'set'
require_relative '../id3file'
  
  class ID3v2File < ID3File
    attr_reader :header, :frames
    # MediaFile class methods
    def self.is_implementation?
      false
    end
    def self.supports?(io)
      io.seek(0)
      bytes = io.read(self.header_class.size_in_bytes)
      !self.header_class.regexp.match(bytes).nil?
    end
    # ID3File class methods
    def self.header_class
      ID3v2Header
    end
    def self.getheader(io)
      io.seek(0)
      bytes = io.read(self.header_size)
      self.class.header_class.new(bytes)
    end
    # ID3v2File methods
  end
  
  class ID3v2Header
    def self.regexp
      Regexp.new('(?!x)x', nil, 'N')  # this will never match
    end
    def self.size_in_bytes
      10
    end
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
  



