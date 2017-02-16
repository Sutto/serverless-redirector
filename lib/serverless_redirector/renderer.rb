require 'ostruct'
require 'erb'

module ServerlessRedirector
  class Renderer

    BASE_PATH = ::File.expand_path '../../templates', File.dirname(__FILE__)

    attr_reader :template_name, :template_path

    def initialize(template_name)
      @template_name = template_name
      @template_path = ::File.join BASE_PATH, template_name
    end

    def render(context = {})
      contents = ::File.read(template_path)
      template = ERB.new contents
      ctx_binding = OpenStruct.new(context).instance_eval { binding }
      template.result ctx_binding
    end

  end
end