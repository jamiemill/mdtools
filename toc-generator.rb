# Generates a table of contents for an html page
# by looking at its heading tags.
#
# Also outputs modified HTML where the heading tags have
# been given anchors to be targetted by the TOC links.
#
# WARNING: this will barf if the headings skip levels, e.g.
# h1 -> h3 without going via h2. Fix this somehow by inserting
# dummy intermediate headings


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
    heading_counter = 1
    headings.each do |heading|
      depth = heading.name.gsub(/h/i, '').to_i
      text = heading.text
      e = TocEntry.new
      e.name = text
      e.counter = heading_counter
      last_entry_refs_by_depth[depth-1].children << e
      last_entry_refs_by_depth[depth] = e
      heading_counter += 1
    end

    html_for_toc toc
  end

  # Recusive function

  def html_for_toc(toc)
    out = ''
    out << '<a href="#section-'+toc.counter.to_s+'">' + toc.name + "</a>\n" unless toc.is_root
    if !toc.children.empty?
      out << "<ul>\n"
      toc.children.each do |c|
        out << "<li>\n" + html_for_toc(c) + "</li>\n"
      end
      out << "</ul>\n"
    end
    out
  end

  def get_linked_html

  end

end

class TocEntry
  attr_accessor :name, :children, :is_root, :counter
  def initialize
    @children = Array.new
  end
end
