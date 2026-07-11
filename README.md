# A Dana Life website

[![Version](https://img.shields.io/github/v/release/adanalife/website?sort=semver&include_prereleases)](https://github.com/adanalife/website/releases)
[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/)

The source for [https://www.dana.lol](https://www.dana.lol) — Dana's personal site and blog. It's a static site built with [Middleman](https://middlemanapp.com/).

## Local development

Ruby 3.4 is pinned in `.tool-versions` (managed with [mise](https://mise.jdx.dev/)):

```sh
mise install
bundle install
bundle exec middleman server
```

The dev server runs at [http://localhost:4567](http://localhost:4567).

Common tasks live in the [Taskfile](https://taskfile.dev/) (`task --list` for the full set):

```sh
task build          # full build with image optimization
task release:stage  # build (fast) + deploy to Cloudflare Pages staging
task release:prod   # build + deploy to Cloudflare Pages production
```

## Deploys

The site deploys to [Cloudflare Pages](https://pages.cloudflare.com/) via wrangler. The legacy S3 + CloudFront setup (`cloudformation/`, the `*:s3` tasks) is retained only as a rollback fallback.

Branch flow:

- **`main`** is the only long-lived branch — feature PRs target it and squash-merge (the PR title becomes the commit subject, so it must be a [Conventional Commit](https://www.conventionalcommits.org/)). Every PR gets a preview deploy at `<branch>.dana-lol-staging.pages.dev` (see `testing.yml`), and every merge deploys staging (`staging.yml`).
- Releases are cut by [release-please](https://github.com/googleapis/release-please), which maintains a standing release PR on `main` with the next version and `CHANGELOG.md` entry computed from the conventional commits. Merging that PR tags `vX.Y.Z`, publishes the GitHub Release, and triggers the production deploy (`release.yml`).

## Contact form

The site is static, but a small Sinatra app backs [the contact page](https://www.dana.lol/contact) and [/ama](https://www.dana.lol/ama). It lives in the [`contact-form` repo](https://github.com/adanalife/contact-form).
