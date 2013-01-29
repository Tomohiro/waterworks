require 'open-uri'
require 'mechanize'
require 'nokogiri'

module Waterworks
  class Extractor
    def initialize(url, store = '~/Downloads')
      @agent = agent(url)
      @store = File.expand_path(store)
    end

    def save
      save_to = "#{@store}/#{series}/#{season}"
      mkdir(save_to)

      resources.each do |resource|
        puts "wget -O '#{save_to}#{resource.destination}' '#{resource.source}'"
      end
    end

    protected
      def agent(url)
        Nokogiri::HTML(open(url))
      end

      def resource(name, uri, suffix = '')
        Resource.new(name, uri, suffix)
      end

      # return the series name
      def series; end

      # return the season name
      def season; end

      # return the title
      def title; end

      # return the download file path list
      def resources; end

    private
      def mkdir(path)
        puts "mkdir -p #{path}"
      end
  end
end
