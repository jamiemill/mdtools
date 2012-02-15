#!/usr/bin/env ruby

require './toc-generator.rb'

SCRIPT_BASE = File.dirname(__FILE__)
TMPFILE='/tmp/markdownpreview.html'

HEAD_TEMPLATE = SCRIPT_BASE + '/head.html'
FOOT_TEMPLATE = SCRIPT_BASE + '/foot.html'

head = IO.read(HEAD_TEMPLATE)
foot = IO.read(FOOT_TEMPLATE)

if File.exists? TMPFILE
  File.unlink TMPFILE
end

File.open(TMPFILE, 'w') do |f|
  f.write head

  input = STDIN.read
  html = ''
  IO.popen('markdown --html4tags', 'r+') do |pipe|
    pipe.puts(input)
    pipe.close_write
    html = pipe.read
  end
  toc = TocGenerator.new(html)
  f.write toc.generate_toc
  f.write toc.get_linked_html
  f.write foot
end

`open #{TMPFILE}`
