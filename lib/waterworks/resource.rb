module Waterworks
  class Resource
    def initialize(params)
      @uri    = params.fetch(:uri)
      @name   = params.fetch(:name, File.basename(@uri))
      @suffix = params.fetch(:suffix, nil)
      @size   = params.fetch(:size, 0)
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
