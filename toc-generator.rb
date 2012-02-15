require 'nokogiri'

class TocGenerator
  def initialize(html)
    @html = html
  end

  def generate_toc
    doc = Nokogiri::HTML::DocumentFragment.parse @html
    toc = TocEntry.new
    toc.name = 'ROOT'
    toc.is_root = true
    headings = doc.css('h1,h2,h3,h4,h5,h6')
    last_entry_refs_by_depth = {
      0 => toc
    }
    headings.each do |heading|
      depth = heading.name.gsub(/h/i, '').to_i
      text = heading.text
      puts text+depth.to_s
      e = TocEntry.new
      e.name = text
      puts last_entry_refs_by_depth[depth-1].class
      last_entry_refs_by_depth[depth-1].children << e
      last_entry_refs_by_depth[depth] = e
    end

    html_for_toc toc
  end

  def html_for_toc(toc)
    out = ''
    out << toc.name+"\n" unless toc.is_root
    if !toc.children.empty?
      out << "<ul>\n"
      toc.children.each do |c|
        out << "<li>\n"
        out << html_for_toc(c)
        out << "</li>\n"
      end
      out << "</ul>\n"
    end
    out
  end

  def get_linked_html

  end

end

class TocEntry
  attr_accessor :name, :children, :is_root
  def initialize
    @children = Array.new
  end
end
