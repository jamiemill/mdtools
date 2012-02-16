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

module MDTools
  class TocGenerator

    HEADING_SELECTOR = 'h1,h2,h3,h4,h5,h6'

    def initialize(html)
      @html = html
    end

    def generate_toc
      toc = generate_toc_obj
      '<div class="toc"><h2>Contents</h2>' + html_for_toc(toc) + '</div>'
    end

    def generate_toc_obj
      doc = get_doc_nokogiri
      toc = TocEntry.new
      toc.name = 'ROOT'
      toc.is_root = true
      headings = doc.css(HEADING_SELECTOR)
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

        parent = last_entry_refs_by_depth[depth-1]

        # if headings skip levels there could be a missing parent
        # so we walk up the tree until we find a valid parent.
        # TODO: Fix this up and write tests. May be a better way.
        if parent.nil?
          tmpdepth = depth-1
          while parent.nil?
            parent = last_entry_refs_by_depth[tmpdepth]
            tmpdepth -= 1
          end
        end

        parent.children << e
        last_entry_refs_by_depth[depth] = e
        heading_counter += 1
      end
      toc
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
      doc = get_doc_nokogiri
      headings = doc.css(HEADING_SELECTOR)
      heading_counter = 1
      headings.each do |heading|
        heading['id'] = 'section-'+heading_counter.to_s
        heading_counter += 1
      end
      doc.to_html
    end

    def get_root_title
      toc = generate_toc_obj
      if toc.children.empty?
        return "No title"
      end
      toc.children.first.name
    end

    private

    def get_doc_nokogiri
      Nokogiri::HTML::DocumentFragment.parse @html
    end

  end

  class TocEntry
    attr_accessor :name, :children, :is_root, :counter
    def initialize
      @children = Array.new
    end
  end
end
