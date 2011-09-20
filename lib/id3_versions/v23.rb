module ID3Tag
  
  class ID3v2_3 < ID3v2
    
    def self.header_regexp
      Regexp.new('ID3\x03[\x00-\xEF][\x00-\xFF][\x00-\x7F]{4}', nil, 'N')
    end
    def self.header_class
      ID3Tag::ID3v2_3Header
    end
    def self.header_size
      10
    end
    def self.version
      2.3
    end
    
  end
  
  class ID3v2_3Header < ID3v2Header
    def flags_bitmap
      {
        :unsynchronisation  =>  7,  7 => :unsynchronisation,
        :extended_header    =>  6,  6 => :extended_header,
        :experimental       =>  5,  5 => :experimental,
      }
    end
  end
    
  class ID3v2_3Frame < ID3v2Frame
    
  end
  
end