#!/usr/bin/env ruby
# frozen_string_literal: true

# Images enter source/ through script/ingest-image, which writes optimized
# bytes, but nothing forces that: a photo dragged straight into an article
# directory ships a raw export, and the repo quietly stops holding what it
# claims to. This exits non-zero when a staged image could still be losslessly
# shrunk by more than THRESHOLD.
#
# Lossless only. It never compares against a re-encode at a different quality —
# that is a judgement call about how the photo should look, not something a
# hook gets to make. What it catches is bytes nobody chose: an unoptimized
# Huffman table, a baseline JPEG that should be progressive, EXIF and thumbnail
# blobs riding along in a file that strips them everywhere else.
#
# Every JPEG and PNG in source/ sits at this floor, so a finding here is a new
# file that skipped the ingest script, not a backlog.
#
# Needs jpegoptim (JPEGs) and optipng (PNGs) on PATH. Without one the check
# warns and skips that format rather than failing, so it can't block a commit
# on a machine that hasn't installed it; CI installs both, which is where the
# verdict that counts is taken.

require 'open3'
require 'tmpdir'

# 2% is the noise floor: below it a "saving" is an encoder tie-break rather
# than bytes anyone chose to ship.
THRESHOLD = 0.02

JPEG_EXT = %w[.jpg .jpeg].freeze
PNG_EXT = %w[.png].freeze

def tool?(name)
  system('command', '-v', name, out: File::NULL, err: File::NULL)
end

# optimized_size returns the bytes path would occupy after a lossless pass, or
# nil when no tool for its format is installed.
def optimized_size(path, tmp)
  ext = File.extname(path).downcase
  copy = File.join(tmp, "probe#{ext}")
  IO.copy_stream(path, copy)

  # --strip-all matches what ingest-image writes. Both tools decline to write a
  # file they would make bigger, leaving the copy untouched, which is exactly
  # the "already at the floor" answer.
  if JPEG_EXT.include?(ext) && tool?('jpegoptim')
    Open3.capture3('jpegoptim', '--strip-all', '-q', copy)
  elsif PNG_EXT.include?(ext) && tool?('optipng')
    Open3.capture3('optipng', '-quiet', '-o2', '-strip', 'all', copy)
  else
    return nil
  end

  File.size(copy)
end

files = ARGV.select { |f| File.file?(f) }
skipped = []
findings = []

Dir.mktmpdir do |tmp|
  files.each do |path|
    before = File.size(path)
    next if before.zero?

    after = optimized_size(path, tmp)
    if after.nil?
      skipped << path
      next
    end

    saving = (before - after).to_f / before
    findings << [path, before, after, saving] if saving > THRESHOLD
  end
end

unless skipped.empty?
  warn "image-shrinkable: jpegoptim/optipng not installed; skipped #{skipped.size} file(s)."
  warn '  brew install jpegoptim optipng'
end

exit 0 if findings.empty?

warn "#{findings.size} image(s) ship bytes a lossless pass would remove:"
findings.each do |path, before, after, saving|
  warn format('  %-60s %8d -> %8d  (-%.1f%%)', path, before, after, saving * 100)
end
warn ''
warn 'Re-ingest them so the repo holds optimized bytes:'
warn "  task img:add -- <article-dir> #{findings.map(&:first).join(' ')}"
warn 'or, for a PNG that should not be watermarked (icons, diagrams):'
warn '  optipng -o2 -strip all <file>'
exit 1
