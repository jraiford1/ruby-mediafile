  class ID3Frame
    attr_accessor :identifier, :bytes, :text_values
    def initialize
      @text_values = []
    end
  end


  class ID3Tag
    attr_accessor :offset, :size, :seek, :header, :ext_header, :frames, :footer
    attr_reader :header_flags, :ext_header_flags
    
    def self.footer_size
      self.header_size
    end
    def self.read_header(file)
        bytes = (file.read(self.header_size))
        return bytes if !self.header_regexp.match(bytes).nil?
        nil
    end
    def self.read_footer(file)
        bytes = (file.read(self.footer_size))
        return bytes if !self.footer_regexp.match(bytes).nil?
        nil
    end
    
    def self.read_next_header(file)
      d3 = "ID3".encode("BINARY")
      while !file.eof?
        return nil if file.binseek(id3, :forwards).nil?
        pos = file.pos
        bytes = self.read_header(file)
        return bytes if !bytes.nil?
        file.seek(pos + id3.size)
      end
      nil
    end
    
    def self.read_last_footer(file)
      threedi = "3DI".encode("BINARY")
      while !file.eof?
        return nil if file.binseek(threedi, :backwards).nil?
        pos = file.pos
        bytes = self.read_header(file)
        return bytes if !bytes.nil?
        file.seek(pos + threedi.size)
      end
      nil
    end
    def tag_size_without_header
      0
    end
    def read_header_flags
      @header_flags = []
    end
    def read_ext_header_flags
      @ext_header_flags = []
    end
    def flag?(a_symbol)
      self.read_header_flags if @header_flags.nil?
      self.read_ext_header_flags if @ext_header_flags.nil?
      @header_flags.include?(a_symbol) or @ext_header_flags.include?(a_symbol)
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
      
      self.read_extended_header(bytesio) if self.flag?(:extended_header)
      self.read_frames(bytesio)
    end
    def read_frames(bytesio)
      
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
    def self.open_on(file)
      instance = self.open_on_prim(file)
      instance.read_tags
      return nil if instance.tags.size == 0
      instance
    end
    def tag_locations
      []
    end
    
    def read_tags
      @tags = []
      if self.tag_locations.include?(:first)  # all v2 tags
        @file.seek(0)
        header = self.class.tag_class.read_header(@file)
        return nil if header.nil? and self.tag_locations.include?(:requires_first)  # v2.2 and v2.3
        offset = 0
        tags << tag = self.class.tag_class.new(self, @file, offset, header)
      end
      if !tag.nil? and !tag.last? and self.tag_locations.include?(:middle)  #v2.4+
        begin
          @file.seek(tag.seek)
          header = self.class.tag_class.read_next_header(@file)
          if !header.nil?
            offset = @file.pos - header.size
            tag = self.class.tag_class.new(self, @file, offset, header)
            @tags << tag if !tag.nil?
          end
        end until tag.nil? or tag.last?
        @tags.last.last = true
      end
      if (@tags.size == 0) and self.tag_locations.include?(:last)  # v1 and v2.4+
        offset = @file.size - self.class.tag_class.footer_size
        @file.seek(offset)
        footer = self.class.tag_class.read_footer(@file)
        if footer.nil? and self.tag_locations.include?(:near_last)  # v2.4+ only
          # TODO: search backwards for tag from end of file
          # this could be implemented, but if a .mp3 file has no tags, this will cause
          # a huge delay when processing the file
        end
        return nil if footer.nil?
        tag = self.class.tag_class.new(self, @file, offset, footer)
        @tags << tag if !tag.nil?
      end
      return nil if @tags.size == 0
      @tags
    end
    
  end
