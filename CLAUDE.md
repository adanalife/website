# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal travel blog ([dana.lol](https://www.dana.lol)) built with **Middleman** (Ruby static site generator). Content is written in Markdown+ERB (`.html.md.erb`), built to static HTML, and deployed to AWS S3 + CloudFront.

## Commands

```bash
bundle install                        # Install dependencies
bundle exec middleman server          # Start dev server at http://localhost:4567
bundle exec middleman build           # Build to ./build/ (skips image optimization in test env)
bundle exec middleman build --bail    # Build and abort on first error (used in CI)
ENV=test bundle exec middleman build  # Build without image optimization (faster)
bundle exec s3_website push           # Deploy to S3 + CloudFront (requires AWS env vars)
```

## Architecture

### Content
- Blog articles: `source/YYYY-MM-DD-title.html.md.erb` (Markdown + ERB, YAML front matter)
- Article images live in per-article subdirectories: `source/YYYY-MM-DD/`
- A photo landing page is automatically proxied for every `.jpg`/`.png` found in those subdirectories (see `config.rb`)
- Data files: `data/settings.yml` (site URL/title), `data/faq.yml`, `data/ogp/` (Open Graph metadata)

### Templates & Helpers
- Main layout: `source/layout.erb`
- Custom ERB helpers: `helpers/dana_lol_helpers.rb` — all available in templates
  - `figure(src)` / `f(src)` — standard figure with link to photo page
  - `full_figure(src)` / `ff(src)` — full-width figure
  - `sidenote(text)` / `sn(text)` — Tufte-style sidenote with auto-incrementing CSS id
  - `marginnote(text)` / `mn(text)` — margin note
  - `epigraph(text, footer)` / `quote(text)` — blockquote with optional footer
  - `newthought(text)` / `nt(text)` — small-caps span for paragraph openings

### Build & Deploy
- CI runs `bundle exec middleman build --bail` on PRs (with `ENV=test` to skip image optimization)
- Merges to `master` trigger build + deploy via `s3_website push`
- Deployment config: `s3_website.yml` (reads `STATIC_SITE_BUCKET` and `STATIC_SITE_CLOUDFRONT` env vars)
- CloudFront cache invalidation runs automatically on deploy

### Infrastructure
- AWS infrastructure defined in `cloudformation/` (Route53, S3, CloudFront)
- Contact form is a separate app: `dmerrick/danalol-contact-form`
