require 'uri'

require 'serverless_redirector/destination'
require 'serverless_redirector/syncer'
require 'serverless_redirector/manifest'

module ServerlessRedirector
  class Controller

    # Configuration has some options:

    attr_accessor :destination_uri, # Target for the syncing...
                  :manifest_path,   # Where can we find out manifest?
                  :log_path,        # If present, where do we log? (STDOUT, by default)
                  :dry_run,         # Is this a dry run?
                  :skip_deletes,    # Deletes have a special ordering to take place to avoid downtime.

    def initialize(options = {})
      @dry_run = false
      @log_path = nil
      @destination_uri = nil
      @manifest_path = nil
      @skip_deletes = false
      unpack_options options
    end

    def unpack_options(options)
      @dry_run = !!options[:dry_run] if options.key?(:dry_run)
      @skip_deletes = !!options[:skip_deletes] if options.key?(:skip_deletes)

      @manifest_path   = options.fetch(:manifest_path) if options.key?(:manifest_path)
      @log_path        = options.fetch(:log_path) if options.key?(:log_path)
      @destination_uri = options.fetch(:destination_uri) if options.key?(:destination_uri)
    end

    def validate
      raise ArgumentError.new("Manifest path does not exist") unless manifest_path && ::File.exist?(manifest_path)
      raise ArgumentError.new("Destination URI Invalid") unless destination_uri && ::URI.parse(destination_uri).present? 
      # Otherwise fine here...
    end

    def invoke!
      logger = create_logger
      manifest = create_manifest
      destination = create_destination

      syncer = ServerlessRedirector::Syncer.new(manifest, destination, logger, skip_deletes)
      syncer.run dry_run
    end

    protected

    def create_logger
      ::Logger.new(log_path || STDOUT)
    end

    def create_destination
      parsed_uri = URI.parse(destination_uri)
      case parsed_uri.scheme
      when "file"
        ServerlessRedirector::LocalDestination.new(parsed_uri)
      when "s3"
        ServerlessRedirector::S3Destination.new(parsed_uri)
      when "nop"
        # Mock / NOOP destination....
        ServerlessRedirector::Destination.new
      else
        raise ArgumentError.new("We do not support #{parsed_uri.scheme} as a known URI scheme.")
      end
    end

    def create_manifest
      ServerlessRedirector::Manifest.load_file! manifest_path
    end


  end
end
