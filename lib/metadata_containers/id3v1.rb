require_relative 'id3_container'
  
  class ID3v1Frame < ID3Frame
    
  end
  
  class ID3v1Tag < ID3Tag
    def self.footer_size
      128
    end
    
    def self.footer_regexp
      /TAG/n
    end
  end
  
  class ID3v1Container < ID3Container
    
    def self.tag_class
      ID3v1Tag
    end
    
    def tag_locations
      [:last]
    end
  end