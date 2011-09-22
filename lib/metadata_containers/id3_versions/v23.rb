
require_relative '../id3file'

  class ID3v23File < ID3v2File
    # MediaFile class methods
    def self.is_implementation?
      true
    end
    # ID3 methods
    def self.header_class
      ID3v23Header
    end
    def self.version
      2.3
    end
    
  end
  
  class ID3v23Header < ID3v2Header
    def self.regexp
      Regexp.new('ID3\x03[\x00-\xEF][\x00-\xFF][\x00-\x7F]{4}', nil, 'N')
    end
    def flags_bitmap
      {
        :unsynchronisation  =>  7,  7 => :unsynchronisation,
        :extended_header    =>  6,  6 => :extended_header,
        :experimental       =>  5,  5 => :experimental,
      }
    end
  end
    
  class ID3v23Frame < ID3v2Frame
    
  end
  