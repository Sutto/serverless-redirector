require 'aws-sdk'

module ServerlessRedirector
  class Destination

    REDIRECT_HEADER_KEY = "x-redirector-target".freeze

    # Lists existing redirects on the bucket
    def existing
      []
    end

    def remove_key(key)
      p [:remove_key, key]
    end

    def write_key(key, location, contents)
      p [:write_key, key, location, contents]
    end

  end

  class LocalDestination < Destination

    attr_reader :uri, :path

    def initialize(uri)
      @uri = uri
      @path = File.join uri.host, uri.path
    end

    def existing
      Dir[File.join(@path, "**/*.json")].map do |json_path|
        contents = JSON.parse(File.read(json_path))
        ServerlessRedirector::Manifest::Redirect.new(contents)
      end.compact
    end

    def remove_key(key)
      html_path = File.join(@path, "#{key}.html")
      File.delete(html_path) if File.exist?(html_path)
      json_path = File.join(@path, "#{key}.json")
      File.delete(json_path) if File.exist?(json_path)
    end

    def write_key(key, location, contents)
      html_path = File.join(@path, "#{key}.html")
      FileUtils.mkdir_p File.dirname(html_path)
      File.write html_path, contents
      json_path = File.join(@path, "#{key}.json")
      File.write json_path, JSON.dump(url: location, path: key)
    end

  end

  class S3Destination < Destination

    attr_reader :uri, :bucket_name, :prefix

    def initialize(uri)
      @uri = uri
      @bucket_name = uri.host
      @prefix = uri.path.to_s.empty? ? nil : ::File.join(uri.path[1..-1], "")
    end

    def existing
      bucket.objects(prefix: prefix).map(&:object).select do |o|
        !o.metadata[REDIRECT_HEADER_KEY].to_s.empty?
      end.map do |o|
        path = o.key.dup
        path.gsub! /^#{Regexp.escape(prefix)}\/?/, '' if prefix
        ServerlessRedirector::Manifest::Redirect.new 'path' => path, 'url' => o.metadata["x-redirector-target"].to_s
      end
    end

    def remove_key(key)
      path = build_path key
      bucket.object(path).delete
    end

    def write_key(key, location, contents)
      # Remove the prefix to the path...
      path = build_path(key).gsub(/\A\/+/, '')
      bucket.put_object({
        acl: "public-read",
        content_type: "text/html",
        body: contents,
        key: path,
        website_redirect_location: location,
        metadata: {
          REDIRECT_HEADER_KEY => location
        }
      })
      puts "WRITTEN"
    end

    protected

    def bucket
      @bucket ||= begin
        resource = Aws::S3::Resource.new
        resource.bucket bucket_name
      end
    end

    def build_path(path)
      if prefix
        ::File.join prefix, path
      else
        path
      end
    end

  end

end