  class ID3Frame
    
  end


  class ID3Tag
    attr_accessor :offset, :size, :seek, :header, :ext_header, :frames, :footer
    
    def self.read_next_header(file)
      id3 = "ID3".encode("BINARY")
      while !file.eof?
        return nil if file.binseek(id3).nil?
        bytes = (file.read(self.header_size))
        return bytes if !self.regexp.match(bytes).nil?
      end
      nil
    end
    def initialize(container, file, offset, header)
      @container = container
      @file = file
      @offset = offset
      @header = header
      
      # we have the header, so read the rest of the tag
      @file.seek(@offset + @header.size)
      @bytes = file.read(self.tag_size_without_header)
      @seek = @offset + @header.size + @bytes.size
      @bytes.gsub!(/\xFF\x00/n, "\xFF".force_encoding("BINARY")) if self.flag?(:unsynchronisation)
      @last = true
      
      bytesio = StringIO.new(@bytes)
      
      self.read_extended_header(bytesio)
      
      # Finally, read the frames that make up the tag
      @frames = []
      @padding = 0
      begin
        if (b = bytesio.getbyte) == 0
          @padding += 1
        else
          bytesio.ungetbyte(b)
          @frames << self.class.frame_class.new(bytesio)
        end
      end until bytesio.eof?
    end
    def last?
      @last == true
    end
    def read_extended_header(io)
      
      # Read the extended header, if present
      if self.flag?(:extended_header)
        @ext_header = io.read(4)
        @ext_header << io.read(self.ext_header_size - 4) 
      end
    end
  end
  
  class ID3Container < MetadataContainer
    attr_accessor :tags
    def first_tag_location
      0
    end
    
    def read_tags
      @tags = []
      tag = nil
      begin
        tag = self.get_next_tag(tag)
        @tags << tag if !tag.nil?
      end until tag.nil?
      @tags
    end
    
    def get_next_tag(prev_tag)
      if prev_tag.nil?
        seek = self.first_tag_location
      else
        return nil if prev_tag.last?
        seek = prev_tag.seek
      end
      @file.seek(seek)
      
      # First read the header and return if its not present
      header = self.class.tag_class.read_next_header(@file)
      return nil if header.nil?
      offset = @file.pos - header.size
      tag = self.class.tag_class.new(self, @file, offset, header)
      
      
    end
  end
