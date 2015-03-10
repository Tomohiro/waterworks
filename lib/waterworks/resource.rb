module Waterworks
  class Resource
    attr_reader :source

    def initialize(params)
      @source = params.fetch(:uri)
      @name   = params.fetch(:name, File.basename(source))
      @suffix = params.fetch(:suffix, nil)
      @size   = params.fetch(:size, 0)
    end

    def destination
      [@name, @suffix].join.gsub('/', '-')
    end

    def size_mb
      return if @size == 0
      @size / 1024 / 1024
    end
  end
end
