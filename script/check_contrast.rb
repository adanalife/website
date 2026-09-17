#!/usr/bin/env ruby
# frozen_string_literal: true

# Every colour the site paints text in comes from a token in
# source/assets/_theme.scss, declared once per theme. A pair that falls under
# WCAG AA (4.5:1 for the body sizes this site uses — nothing is large enough or
# bold enough to qualify for the 3:1 allowance) is invisible in the diff and
# only shows up in a Lighthouse run nobody is watching. This exits non-zero when
# a foreground token fails against its own theme's background.
#
# Only text pairs are checked. --color-border paints a decorative <hr> and
# --color-btn-* sit over photographs, so neither has a fixed background to
# measure against.

ROOT = File.expand_path('..', __dir__)
THEME = 'source/assets/_theme.scss'
MINIMUM = 4.5

# Foreground tokens painted as text, and the token holding what sits behind them.
TEXT_PAIRS = [%w[--color-text --color-bg], %w[--color-muted --color-bg]].freeze

def relative_luminance(hex)
  channels = hex.scan(/../).map do |pair|
    c = pair.to_i(16) / 255.0
    c <= 0.04045 ? c / 12.92 : (((c + 0.055) / 1.055)**2.4)
  end
  (0.2126 * channels[0]) + (0.7152 * channels[1]) + (0.0722 * channels[2])
end

def contrast(fg, bg)
  light, dark = [relative_luminance(fg), relative_luminance(bg)].minmax.reverse
  (light + 0.05) / (dark + 0.05)
end

# `#abc` and `#aabbcc` are the same colour; everything else (a named colour, a
# var() indirection) has no luminance this script can read, so it says so rather
# than skipping the pair silently.
def expand(value, token, theme)
  hex = value.strip.delete_prefix('#')
  return hex.chars.map { |c| c * 2 }.join if hex.match?(/\A\h{3}\z/)
  return hex if hex.match?(/\A\h{6}\z/)

  abort "#{token} in #{theme} is `#{value.strip}`, which is not a hex colour — " \
        'this check can only measure hex values.'
end

# Each `<selector> { … }` block in the file is one theme's token set. Line
# comments go first so they don't land in a block's selector.
source = File.read(File.join(ROOT, THEME)).gsub(%r{^\s*//.*$}, '')
themes = source.scan(/([^{}]+)\{([^}]*)\}/m).map do |selector, body|
  tokens = body.scan(/(--[\w-]+)\s*:\s*([^;]+);/).to_h
  [selector.strip.gsub(/\s+/, ' '), tokens]
end.reject { |_, tokens| tokens.empty? }

abort "No token blocks found in #{THEME} — has the file moved?" if themes.empty?

problems = themes.flat_map do |theme, tokens|
  TEXT_PAIRS.filter_map do |fg_token, bg_token|
    fg, bg = tokens.values_at(fg_token, bg_token)
    next unless fg && bg

    ratio = contrast(expand(fg, fg_token, theme), expand(bg, bg_token, theme))
    next if ratio >= MINIMUM

    format('%<theme>s: %<fg>s (%<fgv>s) on %<bg>s (%<bgv>s) is %<ratio>.2f:1',
           theme: theme, fg: fg_token, fgv: fg.strip, bg: bg_token, bgv: bg.strip, ratio: ratio)
  end
end

if problems.empty?
  puts "#{THEME}: every text token clears #{MINIMUM}:1 against its background"
  exit 0
end

warn "#{THEME} has text below WCAG AA (#{MINIMUM}:1):"
problems.each { |problem| warn "  - #{problem}" }
exit 1
