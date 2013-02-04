class Railscasts < Waterworks::Extractor
  def domain
    'http://railscasts.com'
  end

  def series
    'RailsCasts'
  end

  def title
    @agent.search('h1').text
  end

  def resources
    movie_uri = movie_location
    size      = movie_size(movie_uri)

    [Waterworks::Resource.new(title, movie_uri, '.mp4', size)]
  end

  private
    def movie_location
      @agent.search('.downloads/li/a').each do |a|
        uri = a.attributes['href'].text
        return uri if uri =~ /.+mp4$/
      end
    end

    def movie_size(uri)
      headers = http_response_headers(uri)
      movie_source_not_found = 0

      headers.fetch('content-length', movie_source_not_found).to_i
    end
end
