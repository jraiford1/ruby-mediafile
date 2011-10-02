
require_relative 'id3v2'

    
  class ID3v24Frame < ID3v2Frame
    
    # Subclasses should always implement these methods
    def self.header_size
      10
    end
    def frame_size
      size = @header.getbyte(4)
      size = (size << 7) + @header.getbyte(5)
      size = (size << 7) + @header.getbyte(6)
      size = (size << 7) + @header.getbyte(7)
    end
  end
  
  class ID3v24Tag < ID3v2Tag
    
    # Subclasses should always implement these methods
    def self.header_size
      10
    end
    def self.header_regexp
      /ID3\x04[\x00-\xEF][\x00-\xFF][\x00-\x7F]{4}/n
    end
    def self.frame_class
      ID3v24Frame
    end
    def header_flags_bitmap
      {
        :unsynchronisation  =>  7,  7 => :unsynchronisation,
        :extended_header    =>  6,  6 => :extended_header,
        :experimental       =>  5,  5 => :experimental,
        :footer_present     =>  4,  4 => :footer_present,
      }
    end
    def ext_header_flags_bitmap
      {
        :tag_is_an_update   =>  6,  6 => :tag_is_an_update,
        :crc_data_present   =>  5,  5 => :crc_data_present,
        :tag_restrictions   =>  4,  4 => :tag_restrictions,        
      }
    end
    def tag_size_without_header
      size = @header.getbyte(6)
      size = (size << 7) + @header.getbyte(7)
      size = (size << 7) + @header.getbyte(8)
      size = (size << 7) + @header.getbyte(9)
    end
    # ------------------------------------------------
    
  end
  
  class ID3v24Container < ID3v2Container
    
    def self.tag_class
      ID3v24Tag
    end
    
    def tag_locations
      [:first, :middle, :last, :near_last]
    end
  end
  
  