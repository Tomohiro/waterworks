class Himado < Waterworks::Extractor
  def series
    @agent.search('span#seriestag/a').text
  end

  def title
    @agent.search('#movie_title').text
  end

  def resources
    resources = []
    movie_mirrors do |movie_uri|
      size = movie_size(movie_uri)
      if is_high_definition?(size)
        return [Waterworks::Resource.new(title, movie_uri, '.m4v', size)]
      end
    end
    resources
  end

  private
    def movie_mirrors
      @agent.search('#select_othersource/option').each do |option|
        agent("http://himado.in/#{option.attributes['value']}").search('script').each do |script|
          next unless script.text =~ /display_movie_url = '(?<movie>.+)';/

          movie_uri = URI.unescape($~[:movie])
          headers = get_headers(movie_uri)

          yield headers['Location'] || movie_uri
        end
      end
    end

    def get_headers(uri, redirect_limit = 5)
      raise ArgumentError, 'HTTP redirect too deep' if redirect_limit == 0

      uri = URI.parse(uri)
      headers = {}
      Net::HTTP.start(uri.host) do |http|
        headers = http.head(uri.path)
      end

      case headers
      when Net::HTTPOK
        headers
      when Net::HTTPFound
        uri = headers['Location']
        get_headers(uri, redirect_limit - 1)
      end
      headers
    end

    def movie_size(uri)
      headers = get_headers(uri)
      movie_source_not_found = 0

      headers.fetch('content-length', movie_source_not_found).to_i
    end

    def is_high_definition?(movie_size)
      high_definition_size_min = 1024 * 1024 * 150 # 150MB
      movie_size > high_definition_size_min
    end
end
