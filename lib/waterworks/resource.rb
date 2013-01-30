module Waterworks
  class Resource
    def initialize(name, uri, suffix = '', size = 0)
      @name   = name
      @uri    = uri
      @suffix = suffix
      @size   = size
    end

    def destination
      "#{@name}#{@suffix}".gsub('/', '-')
    end

    def source
      @uri
    end

    def size_mb
      return if @size == 0
      @size / 1024 / 1024
    end
  end
end
