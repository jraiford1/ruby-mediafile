
require_relative 'id3v2'

    
  class ID3v23Frame < ID3v2Frame
    
    # Subclasses should always implement these methods
    def self.header_size
      10
    end
    def frame_size
      size = @header.getbyte(4)
      size = (size << 8) + @header.getbyte(5)
      size = (size << 8) + @header.getbyte(6)
      size = (size << 8) + @header.getbyte(7)
    end
    # ------------------------------------------------
    
  end
  
  class ID3v23Container < ID3v2Container
    
    # Subclasses should always implement these methods
    def self.regexp
      /ID3\x03[\x00-\xEF][\x00-\xFF][\x00-\x7F]{4}/n
    end
    def self.frame_class
      ID3v23Frame
    end
    def header_flags_bitmap
      {
        :unsynchronisation  =>  7,  7 => :unsynchronisation,
        :extended_header    =>  6,  6 => :extended_header,
        :experimental       =>  5,  5 => :experimental,
      }
    end
    def ext_header_flags_bitmap
      {
        :crc_data_present   => 15, 15 => :crc_data_present,
      }
    end
    # ------------------------------------------------
    
  end
  ID3v23Container.register_version
  
  