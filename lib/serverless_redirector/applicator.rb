require 'thread'

module ServerlessRedirector
  class Applicator

    attr_reader :destination, :logger, :logger_mutex

    def initialize(destination, logger)
      @destination = destination
      @logger = logger
      @logger_mutex = Mutex.new
    end

    def apply(operation)
      case operation
      when ServerlessRedirector::Operations::RemoveRedirect
        destination.remove_key operation.redirect.path
      when ServerlessRedirector::Operations::CreateRedirect, ServerlessRedirector::Operations::UpdateRedirect
        rendered = ServerlessRedirector::Renderer.new('redirect.erb').render(url: operation.redirect.url)
        destination.write_key operation.redirect.path, operation.redirect.url, rendered
      end
      logger_mutex.synchronize { logger.info "=> Applied #{operation.summarize}" }
    rescue => e
      p e
      raise
    end

  end
end
