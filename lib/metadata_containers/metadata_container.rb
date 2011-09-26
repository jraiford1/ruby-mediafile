  class MetadataContainer
    
      attr_accessor :file
      def self.open_on(file)
        inst = self.open_on_prim(file)
        inst.read_metadata
        return nil if !inst.has_metadata?
      end
      def self.open_on_prim(file)
        inst = self.new
        inst.file = file
        inst
      end
  end