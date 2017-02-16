module ServerlessRedirector
  module Operations

    class RedirectOperation

      attr_reader :redirect

      def initialize(redirect)
        @redirect =  redirect
      end

      def summarize
        "#{self.class.name.split("::").last} on #{redirect.path} => #{redirect.url}"
      end

    end

    class RemoveRedirect < RedirectOperation; end
    class UpdateDestination < RedirectOperation; end
    class CreateRedirect < RedirectOperation; end

  end
end