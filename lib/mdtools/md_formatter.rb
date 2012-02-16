require 'mdtools/toc_generator'
require 'erb'

module MDTools
  class MDFormatter

    TEMPLATE_PATH = File.expand_path('../../../templates', __FILE__)
    HEAD_TEMPLATE = TEMPLATE_PATH + '/head.html.erb'
    FOOT_TEMPLATE = TEMPLATE_PATH + '/foot.html.erb'

    def initialize(input, output, options)

      head = ERB.new(IO.read(HEAD_TEMPLATE))
      foot = ERB.new(IO.read(FOOT_TEMPLATE))


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

      # write header
      output.write head.result(binding)

      if options[:add_toc]
        # write TOC
        output.write toc.generate_toc
        # write linked-up body
        output.write toc.get_linked_html
      else
        # just write the unchanged html body
        output.write html
      end

      # write footer
      output.write foot.result(binding)

    end
  end
end
