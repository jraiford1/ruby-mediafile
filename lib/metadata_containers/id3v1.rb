require_relative 'id3_container'
  
  class ID3v1Frame < ID3Frame
    
  end
  
  class ID3v1Tag < ID3Tag
    
  end
  
  class ID3v1Container < ID3Container
    
    def self.tag_class
      ID3v2Tag
    end
    
    def self.open_on(file)
      tags = self.read_tags
      return nil if tags.size == 0
      
      container = tags.first.container.open_on_prim(file)
      container.tags = tags
      container
    end
  end