module HttpEventstore
  class PageUrl

    def initialize(links, stream_name)
      @links = links
      @stream_name = stream_name
    end

    def next
      link = links.detect { |link| link['relation'] == 'next' }
      format(link)
    end

    def previous
      link = links.detect { |link| link['relation'] == 'previous' }
      format(link)
    end

    private
    attr_reader :links, :stream_name

    def format(link)
      if link
        uri = URI.parse(link['uri'])
        params = Hash[uri.path.scan(/\/(\w+)\/(\d+)/)]
        params[stream_name].to_i
      end
    end
  end
end
