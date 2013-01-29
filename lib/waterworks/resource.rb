module Waterworks
  class Resource
    def initialize(name, uri, suffix = '')
      @name   = name
      @uri    = uri
      @suffix = suffix
    end

    def destination
      "#{@name}#{@suffix}"
    end

    def source
      @uri
    end
  end
end
