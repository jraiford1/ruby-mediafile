require_relative 'mediafile'
require_relative 'mp3file'

file = MediaFile.new('/home/jon/test.mp3')
puts file.tags