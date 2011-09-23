
require_relative 'id3v2'

    
  class ID3v22Frame < ID3v2Frame
    
  end
  
  class ID3v22Container < ID3v2Container
    
    # Subclasses should always implement these methods
    def self.regexp
      /ID3\x02[\x00-\xEF][\x00-\xFF][\x00-\x7F]{4}/n
    end
    def self.frame_class
      ID3v22Frame
    end
    def header_flags_bitmap
      {
        :unsynchronisation  =>  7,  7 => :unsynchronisation,
        :compression        =>  6,  6 => :compression,
      }
    end
    def ext_header_flags_bitmap
      {}
    end
    # ------------------------------------------------
    
  end
  ID3v22Container.register_version
  
  