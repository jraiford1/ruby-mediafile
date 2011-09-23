require_relative 'metadata_container'
require_relative 'id3tag'
require 'stringio'
require 'set'

  # Implement Frame class first because its referenced in the Container class
  class ID3v2Frame
    
    # Subclasses should always implement these methods
    def self.header_size
      raise "Method not implemented by subclass"
    end
    def frame_size
      raise "Method not implemented by subclass"
    end
    # ------------------------------------------------
    
    def initialize(io)
      @header = io.read(self.class.header_size)
      @frame = io.read(self.frame_size)
      
    end
  end
  
  class ID3v2Container < MetadataContainer
    @@versions = []
    
    # Subclasses should always implement these methods
    def self.regexp
      Regexp.new('(?!x)x', nil, 'N')  # this will never match
    end
    def self.frame_class
      ID3v2Frame
    end
    def header_flags_bitmap
      {}
    end
    def ext_header_flags_bitmap
      {}
    end
    # ------------------------------------------------
    
    
    # Create the appropriate object based on the version in header
    def self.open_on(file)
      header_bytes = ""
      child_class = @@versions.detect { |cls|
        if cls.header_size != header_bytes.size
          file.seek(0)
          header_bytes = file.read(cls.header_size)
        end
        !cls.regexp.match(header_bytes).nil? }
      return nil if child_class.nil?
      
      child_class.open_on_prim(file)
    end
    def has_metadata?
      !(@tags.nil? or (@tags.size == 0))
    end
    
    def self.register_version
      @@versions << self
    end
    # MetadataContainer methods
    def read_metadata
      @tags = []
      tag = nil
      begin
        tag = self.get_next_tag(tag)
      end until tag.nil?
    end
    
    def seek_next_tag(prev_tag)
      if prev_tag.nil?
        seek = 0
      else
        return nil if prev_tag.last?
        seek = prev_tag.seek
      end
      @file.seek(seek)
      
    end
    
    def get_next_tag(prev_tag)
      tag = ID3Tag.new
      tag.offset = self.seek_next_header(prev_tag)
      
      # First read the header and return if its not present
      @header = file.read(self.class.header_size)
      return if self.class.regexp.match(@header).nil?
      
      # Now read the rest of the tag
      @bytes = file.read(self.header_tag_size)
      @bytes.gsub!(/\xFF\x00/n, "\xFF".force_encoding("BINARY")) if self.flag?(:unsynchronisation)
      
      io = StringIO.new(@bytes)
      
      # Read the extended header, if present
      if self.flag?(:extended_header)
        @ext_header = io.read(4)
        @ext_header << io.read(self.ext_header_size) 
      end
      
      # Finally, read the frames that make up the tag
      @frames = []
      @padding = 0
      begin
        if (b = io.getbyte) == 0
          @padding = @padding.next
        else
          io.ungetbyte(b)
          @frames << self.class.frame_class.new(io)
        end
      end until io.eof?
    end
    
    ## Header Methods
    def self.header_size
      10
    end
    def header_identifier
      @header[0..2]
    end
    def header_version
      [@header.getbyte(3), @header.getbyte(4)].join('.').to_f
    end
    def header_rawflags
      @header.getbyte(5)
    end
    def read_header_flags
      @header_flags = Array.new
      flags = self.header_rawflags
      bitmap = self.header_flags_bitmap
      7.downto(0) do |i|
        if flags[i] == 1
          @header_flags << bitmap[i] if bitmap[i] != nil
        end
      end
    end
    def flag?(a_symbol)
      self.read_header_flags if @header_flags.nil?
      self.read_ext_header_flags if @ext_header_flags.nil?
      @header_flags.include?(a_symbol) or @ext_header_flags.include?(a_symbol)
    end
    def header_tag_size
      size = @header.getbyte(6)
      size = (size << 7) + @header.getbyte(7)
      size = (size << 7) + @header.getbyte(8)
      size = (size << 7) + @header.getbyte(9)
    end
    
    ## Extended Header Methods
    def ext_header_size
      size = @ext_header.getbyte(0)
      size = (size << 8) + @ext_header.getbyte(1)
      size = (size << 8) + @ext_header.getbyte(2)
      size = (size << 8) + @ext_header.getbyte(3)
    end
    def ext_header_rawflags
      (@ext_header.getbyte(5) << 8) + @ext_header.getbyte(6)
    end
    def read_ext_header_flags
      @ext_header_flags = Array.new
      return if !@header_flags.include?(:extended_header)
      flags = self.ext_header_rawflags
      bitmap = self.ext_header_flags_bitmap
      15.downto(0) do |i|
        if flags[i] == 1
          @ext_header_flags << bitmap[i] if bitmap[i] != nil
        end
      end
    end
  end
  
  



