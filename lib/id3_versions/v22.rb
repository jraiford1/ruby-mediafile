module ID3Tag
  
  class ID3v2_2 < ID3v2
    
    def self.header_regexp
      Regexp.new('ID3\x02[\x00-\xEF][\x00-\xFF][\x00-\x7F]{4}', nil, 'N')
    end
    def self.header_class
      ID3Tag::ID3v2_2Header
    end
    def self.header_size
      10
    end
    def self.version
      2.2
    end
    
  end
  
  class ID3v2_2Header < ID3v2Header
    def flags_bitmap
      {
        :unsynchronisation  =>  7,  7 => :unsynchronisation,
        :compression        =>  6,  6 => :compression,
      }
    end
  end
    
  class ID3v2_2Frame < ID3v2Frame
    
  end
  
end