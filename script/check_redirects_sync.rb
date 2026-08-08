#!/usr/bin/env ruby
# frozen_string_literal: true

# dana.lol declares its redirects twice: Cloudflare Pages reads
# source/_redirects, the S3 fallback reads s3_website.yml's `redirects:` map.
# A redirect declared in only one of them works on one host and 404s on the
# other, so the two files must agree. This exits non-zero when they don't.
#
# Every rule the site has today is expressible on both hosts. A Cloudflare-only
# rule (a splat or a :placeholder, which S3 can't express) would have no
# counterpart — adding one means teaching this check to skip it.

require 'yaml'

ROOT = File.expand_path('..', __dir__)
CF_FILE = 'source/_redirects'
S3_FILE = 's3_website.yml'

# The two files spell the same path differently — _redirects needs a leading
# slash, s3_website.yml entries sometimes carry a trailing one — so compare
# paths and targets without their surrounding slashes.
def normalize(path)
  path.sub(%r{\A/}, '').sub(%r{/\z}, '')
end

cf = File.readlines(File.join(ROOT, CF_FILE), chomp: true).map do |line|
  next if line.strip.empty? || line.start_with?('#')

  from, to, = line.split
  [normalize(from), normalize(to)]
end.compact.to_h

s3 = YAML.safe_load(File.read(File.join(ROOT, S3_FILE)))
         .fetch('redirects')
         .map { |from, to| [normalize(from), normalize(to)] }
         .to_h

problems = (cf.keys - s3.keys).sort.map { |k| "/#{k} is in #{CF_FILE} but missing from #{S3_FILE}" }
problems += (s3.keys - cf.keys).sort.map { |k| "/#{k} is in #{S3_FILE} but missing from #{CF_FILE}" }
problems += (cf.keys & s3.keys).sort.map do |k|
  next if cf[k] == s3[k]

  "/#{k} points at #{cf[k]} in #{CF_FILE} but #{s3[k]} in #{S3_FILE}"
end.compact

if problems.empty?
  puts "#{CF_FILE} and #{S3_FILE} agree on all #{cf.size} redirects"
  exit 0
end

warn "#{CF_FILE} and #{S3_FILE} disagree:"
problems.each { |problem| warn "  - #{problem}" }
warn ''
warn 'Declare every redirect in both files so it works on Cloudflare Pages and the S3 fallback.'
exit 1
