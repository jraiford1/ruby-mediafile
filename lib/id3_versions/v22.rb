
require_relative '../id3'

  class ID3v22File < ID3v2File
    
    def self.header_regexp
      Regexp.new('ID3\x02[\x00-\xEF][\x00-\xFF][\x00-\x7F]{4}', nil, 'N')
    end
    def self.header_class
      ID3v22Header
    end
    def self.header_size
      10
    end
    def self.version
      2.2
    end
    
  end
  
  class ID3v22Header < ID3v2Header
    def flags_bitmap
      {
        :unsynchronisation  =>  7,  7 => :unsynchronisation,
        :compression        =>  6,  6 => :compression,
      }
    end
  end
    
  class ID3v22Frame < ID3v2Frame
    
  end
  