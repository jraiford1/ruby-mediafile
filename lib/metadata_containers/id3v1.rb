require_relative 'id3_container'
require_relative 'id3v1genres'
  
  class ID3v1Frame < ID3Frame
    attr_accessor :range
    def values
      if @range.class == Range
        val = @bytes[@range]
        return [] if val.getbyte(0) == 0
        return val.unpack("A*")
      else
        return [ID3_V1_GENRES[@bytes.getbyte(@range)]]
      end
    end
  end
  
  class ID3v1Tag < ID3Tag
    def self.footer_size
      128
    end
    def self.frame_class
      ID3v1Frame
    end
    def self.footer_regexp
      /TAG/n
    end
    def read_frames(bytesio)
      # frames are in the tag so ignore bytesio
      @bytes.force_encoding("ASCII")
      @frames = []
      frames << frame = self.class.frame_class.new
      frame.bytes = @header
      frame.range = 0..2
      frame.identifier = :identifier
      frames << frame = self.class.frame_class.new
      frame.bytes = @header
      frame.range = 3..32
      frame.identifier = :title
      frames << frame = self.class.frame_class.new
      frame.bytes = @header
      frame.range = 33..62
      frame.identifier = :artist
      frames << frame = self.class.frame_class.new
      frame.bytes = @header
      frame.range = 63..92
      frame.identifier = :album
      frames << frame = self.class.frame_class.new
      frame.bytes = @header
      frame.range = 93..96
      frame.identifier = :year
      frames << frame = self.class.frame_class.new
      frame.bytes = @header
      frame.range = 97..126
      frame.identifier = :comments
      frames << frame = self.class.frame_class.new
      frame.bytes = @header
      frame.range = 127
      frame.identifier = :genre
    end
  end
  
  class ID3v1Container < ID3Container
    
    def self.tag_class
      ID3v1Tag
    end
    
    def tag_locations
      [:last]
    end
  end