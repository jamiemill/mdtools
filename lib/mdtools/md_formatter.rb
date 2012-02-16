require 'mdtools/toc_generator'
require 'erb'

module MDTools
  class MDFormatter

    HEAD_TEMPLATE = File.expand_path(File.dirname(__FILE__) + '../../../templates/head.html.erb')
    FOOT_TEMPLATE = File.expand_path(File.dirname(__FILE__) + '../../../templates/foot.html.erb')

    def initialize(input, output)

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

      # write TOC
      output.write toc.generate_toc

      # write linked-up body
      output.write toc.get_linked_html

      # write footer
      output.write foot.result(binding)

    end
  end
end
