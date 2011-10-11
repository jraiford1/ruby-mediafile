module MP4
  ISO_12_BYTES = "0011-0010-8000-00AA00389B71"
  class Box
    def open_on(file)
      @offset = file.pos
      @size = file.read_uint32be
      @type = file.read_partial(4)
      if @size == 1
        @largesize = file.read_uint64be
      elsif @size == 0
        # box extends to end of file
      end
      if (@type == 'uuid')
        @usertype = "{"
        @usertype << file.read_partial(4).unpack("N").to_s(16).upcase
        @usertype << file.read_partial(4).unpack("N").to_s(16).upcase
        @usertype << file.read_partial(4).unpack("N").to_s(16).upcase
        @usertype << file.read_partial(4).unpack("N").to_s(16).upcase
        @usertype << "}"
      else
        @usertype = "{"
        @usertype << @type.unpack("N").to_s(16).upcase
        @usertype << ISO_12_BYTES
        @usertype << "}"
      end
      @usertype = @usertype.to_sym
      true
    end
    def write_on(file)
      file.write_uint32be(@size)
      file.write(@type)
      if @size == 1
        file.write_uint64be(@largesize)
      end
      if (@boxtype == 'uuid')
        file.write(@usertype)
      end
      true
    end
    def create(boxtype, extended_type)
      @size
      @type = boxtype
      if @size == 1
        @largesize
      elsif @size == 0
        # extends to end of file
      end
      if boxtype == 'uuid'
        @usertype = extended_type
      end
      true
    end
    def self.open_on(file)
      inst = self.new
      return nil if !inst.open_on(file)
      inst
    end
    def self.create(*args)
      inst = self.new
      return nil if !inst.create(args)
      inst
    end
  end
  class FullBox < Box
    def open_on(file)
      return false if super.open_on(file) == false
      @version = file.read_uint8be
      @flags = file.read_uint24be
    end
  end
  class FileTypeBox < Box
    def self.boxtype
      "ftyp"
    end
    def open_on(file)
      return false if super.open_on(file) == false
      @major_brand = file.read_partial(4)
      @minor_version = file.read_uint32be
      @compatible_brands = []
      while file.pos < (@offset + self.size)
        @compatible_brands << file.read_partial(4)
      end
    end
  end
  class MediaDataBox < Box
    def self.boxtype
      "mdat"
    end
  end
  class FreeSpaceBox < Box
    def self.boxtype
      "free"
    end
  end
  class SkipSpaceBox < FreeSpaceBox
    def self.boxtype
      "skip"
    end
  end
end