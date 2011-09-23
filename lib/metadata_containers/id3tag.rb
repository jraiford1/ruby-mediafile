  class ID3Tag
    attr_accessor :offset, :size, , :seek, :header, :ext_header, :frames, :footer, :last?
    def initialize
      @last? = false
    end
  end