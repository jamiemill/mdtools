require 'mdtools/toc_generator'
require 'erb'

module MDTools
  class MDFormatter

    DEFAULT_TEMPLATE_PATH = File.expand_path('../../../templates', __FILE__)
    DEFAULT_TEMPLATE = DEFAULT_TEMPLATE_PATH + '/default.html.erb'

    def initialize(input, output, options)

      # these attributes will be called by the template
      @title = ''
      @toc = ''
      @content = ''

      if(options[:template])
        template_path = File.expand_path(options[:template])
      else
        template_path = DEFAULT_TEMPLATE
      end

      template = ERB.new(IO.read(template_path))

      # convert markdown to HTML
      input = STDIN.read
      html = ''
      IO.popen('markdown --html4tags', 'r+') do |pipe|
        pipe.puts(input)
        pipe.close_write
        html = pipe.read
      end
      toc = TocGenerator.new(html)
      @title = toc.get_root_title

      if options[:add_toc]
        # write TOC
        @toc = toc.generate_toc
        # write linked-up body
        @content = toc.get_linked_html
      else
        # just write the unchanged html body
        @content = html
      end

      # write footer
      output.write template.result(binding)

    end
  end
end
