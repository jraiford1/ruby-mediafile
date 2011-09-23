  class MetadataContainer
    
      attr_accessor :file
      def self.open_on(file)
        self.open_on_prim(file)
      end
      def self.open_on_prim(file)
        inst = self.new
        inst.file = file
        inst.read_metadata
        return nil if !inst.has_metadata?
        inst
      end
      def read_metadata
        # Do nothing in base class
      end
      def has_metadata?
        false
      end
  end