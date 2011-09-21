require_relative 'mediafile'
require_relative 'id3'
require_relative 'id3_versions'

file = MediaFile.new('/home/jon/test.mp3')
puts file.tags