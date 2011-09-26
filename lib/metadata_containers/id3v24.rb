
require_relative 'id3v2'

    
  class ID3v24Frame < ID3v2Frame
    
  end
  
  class ID3v24Tag < ID3v2Tag
    
    # Subclasses should always implement these methods
    def self.regexp
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
      }
    end
    def ext_header_flags_bitmap
      {}
    end
    # ------------------------------------------------
    
  end
  
  class ID3v24Container < ID3v2Container
    
  end
  
  