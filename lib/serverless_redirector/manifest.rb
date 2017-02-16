module ServerlessRedirector
  class Manifest

    Redirect = Struct.new(:path, :url) do

      def initialize(h = {})
        super h.fetch('path'), h.fetch('url')
      end

      def serializable_hash(options = {})
        {
          'path' => path,
          'url'  => url
        }
      end

    end

    # Conditions:
    # 1. Everything has a valid path.
    # 2. All URLs are valid

    attr_reader :redirects

    def initialize(contents)
      @redirects = contents.to_a.map { |item| Redirect.new item }.freeze
    end

    def validate
      @redirects.each do |item|
      end
    end

    def self.dump_file!(path)
      File.open path, 'w+' do |out|
        @redirects.each do |redirect|
          out.puts JSON.dump(redirect.serializable_hash)
        end
      end
    end

    def self.load_file!(path)
      contents = File.readlines(path).lazy.map { |line| JSON.parse(line) }
      new contents
    end

  end
end