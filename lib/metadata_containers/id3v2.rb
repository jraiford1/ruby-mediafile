require_relative 'id3_container'
require 'stringio'
require 'set'
require_relative 'iobinseek'

  # Implement Frame class first because its referenced in the Container class
  class ID3v2Frame < ID3Frame
    
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
  
  class ID3v2Tag < ID3Tag
    # Subclasses should always implement these methods
    def self.header_regexp
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
  
  class ID3v2Container < ID3Container
    def self.tag_class
      ID3v2Tag
    end
    
    def self.open_on(file)
      if self == ID3v2Container
        instance = ID3v24Container.open_on(file) if instance.nil?
        instance = ID3v23Container.open_on(file) if instance.nil?
        # instance = ID3v22Container.open_on(file) if instance.nil?  
        return instance
      end
      super
    end
    
  end
  
  require_relative "id3v22"
  require_relative "id3v23"
  require_relative "id3v24"
  



