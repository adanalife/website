# Changelog

## [1.11.2](https://github.com/adanalife/website/compare/v1.11.1...v1.11.2) (2026-09-24)


### Features

* **posts:** link the Virginia video on Instagram and Facebook ([#330](https://github.com/adanalife/website/issues/330)) ([e929c27](https://github.com/adanalife/website/commit/e929c27b296fe14edcf01ae99a5d9c1d0c7d4962))


### Miscellaneous Chores

* **release:** type new articles as `post`, released as a patch ([#332](https://github.com/adanalife/website/issues/332)) ([dd4ac0f](https://github.com/adanalife/website/commit/dd4ac0f58a959919fb1ffcb101c13d6191f2cff2))

## [1.11.1](https://github.com/adanalife/website/compare/v1.11.0...v1.11.1) (2026-09-23)


### Bug Fixes

* **a11y:** raise the light-mode muted grey, and measure the theme tokens ([#317](https://github.com/adanalife/website/issues/317)) ([152dd0d](https://github.com/adanalife/website/commit/152dd0dda231348af20ffcd454b3849ef2484071))
* **ogp:** stop og:title and &lt;title&gt; carrying the rendered page head ([#328](https://github.com/adanalife/website/issues/328)) ([12b1740](https://github.com/adanalife/website/commit/12b17408e73619aad230a46c9424cc019e013be1))

## [1.11.0](https://github.com/adanalife/website/compare/v1.10.0...v1.11.0) (2026-09-21)


### Features

* **contact:** back the contact and AMA forms with the Cloudflare worker ([#325](https://github.com/adanalife/website/issues/325)) ([826c2ad](https://github.com/adanalife/website/commit/826c2ad7354166e7cab9c63ca8c967ae0fbc33d7))


### Bug Fixes

* **theme:** invert the logo in dark mode so it stays readable ([#323](https://github.com/adanalife/website/issues/323)) ([6336267](https://github.com/adanalife/website/commit/6336267b732eafbc423c74062ae67f5fa0630e7a))

## [1.10.0](https://github.com/adanalife/website/compare/v1.9.1...v1.10.0) (2026-09-21)


### Features

* **blog:** Virginia and the Carlton Bridge ([#321](https://github.com/adanalife/website/issues/321)) ([765f1d3](https://github.com/adanalife/website/commit/765f1d3c024746cb08abbb90fd9b0b157d79c385))
* **privacy:** serve YouTube embeds from youtube-nocookie.com ([#311](https://github.com/adanalife/website/issues/311)) ([7017a60](https://github.com/adanalife/website/commit/7017a607d3096cbba16f3e7a3f761fcd1ce31c4d))


### Bug Fixes

* **ci:** serialize release-please runs ([#318](https://github.com/adanalife/website/issues/318)) ([ab80555](https://github.com/adanalife/website/commit/ab80555649ea8c6bc86f583c735d2593929669de))
* **forms:** graceful-error UX on the contact and AMA forms ([#210](https://github.com/adanalife/website/issues/210)) ([f0a491b](https://github.com/adanalife/website/commit/f0a491b339e2ebc6c8febc137cfc8f3f61f39b5f))
* **ogp:** add og:site_name and X card tags to every page ([#322](https://github.com/adanalife/website/issues/322)) ([4e203fc](https://github.com/adanalife/website/commit/4e203fcb105dfd46cc147341b3a2e130f9541894))

## [1.9.1](https://github.com/adanalife/website/compare/v1.9.0...v1.9.1) (2026-09-02)


### Bug Fixes

* **redirects:** point the -opt.JPG image redirects at the lowercased files ([#303](https://github.com/adanalife/website/issues/303)) ([7428e0b](https://github.com/adanalife/website/commit/7428e0b9b296bed300676236deec86c682393e91))

## [1.9.0](https://github.com/adanalife/website/compare/v1.8.0...v1.9.0) (2026-08-29)


### Features

* **images:** add the ingest script (archive, watermark, strip EXIF, alt text) ([#290](https://github.com/adanalife/website/issues/290)) ([c2fce11](https://github.com/adanalife/website/commit/c2fce11342a9a7fea925434b481036f52185127a))
* **images:** optimize images at ingest instead of at build ([#286](https://github.com/adanalife/website/issues/286)) ([cdbdb69](https://github.com/adanalife/website/commit/cdbdb69df7aa59679e9d592279aec21467bbcf18))
* **post:** let the Shortcut join multiple POSTs into one message via id ([#293](https://github.com/adanalife/website/issues/293)) ([0e50a24](https://github.com/adanalife/website/commit/0e50a24ca0f518aeca97300ebe30c5db411bcb71))
* **post:** post-from-phone inbox worker + drain ([#292](https://github.com/adanalife/website/issues/292)) ([1d8f86e](https://github.com/adanalife/website/commit/1d8f86e87abb7a08a043319ae25271a39607df2d))


### Bug Fixes

* **images:** let a retry re-archive identical bytes ([#297](https://github.com/adanalife/website/issues/297)) ([236ebee](https://github.com/adanalife/website/commit/236ebee99bfc70041c45ea152d3234eb10f2955d))
* **images:** test the NAS mount, not the archive dir, before archiving ([#295](https://github.com/adanalife/website/issues/295)) ([a5896c0](https://github.com/adanalife/website/commit/a5896c028c366cf7d602cdd2281628187b393764))
* **post:** delete the local branch when a drain fails so the retry can recreate it ([#294](https://github.com/adanalife/website/issues/294)) ([fbc6be1](https://github.com/adanalife/website/commit/fbc6be1a2f69bb1d0523c35e8f42db3ca213f7d3))
* **post:** use a conventional commit subject for drafted posts ([#298](https://github.com/adanalife/website/issues/298)) ([b1667ce](https://github.com/adanalife/website/commit/b1667ce135e0e100c5bfa898868377746b09f39b))

## [1.8.0](https://github.com/adanalife/website/compare/v1.7.1...v1.8.0) (2026-08-18)


### Features

* **posts:** add metric equivalents to imperial measurements ([#276](https://github.com/adanalife/website/issues/276)) ([020e31a](https://github.com/adanalife/website/commit/020e31a462f8c0e30f7fb21c8706757a998d1e52))


### Bug Fixes

* **posts:** correct double-dot hostname in og:image URLs ([#272](https://github.com/adanalife/website/issues/272)) ([01da47f](https://github.com/adanalife/website/commit/01da47f74f9bd9e5738c80556ca09330845a4687))
* **posts:** use the figure helper for the san diego photo credits ([#274](https://github.com/adanalife/website/issues/274)) ([2ec4a56](https://github.com/adanalife/website/commit/2ec4a566283aa529d922d21620dcf1c05e3be869))
* **seo:** default meta description and unique titles for archive/tag pages ([#273](https://github.com/adanalife/website/issues/273)) ([4015cfc](https://github.com/adanalife/website/commit/4015cfc463821e58cea68c6f8a3c444493341cbe))


### Performance Improvements

* **assets:** cache /assets/ for an hour instead of revalidating ([#268](https://github.com/adanalife/website/issues/268)) ([08bbe26](https://github.com/adanalife/website/commit/08bbe26eef825d36caea15fbbb9a27dedfd50122))

## [1.7.1](https://github.com/adanalife/website/compare/v1.7.0...v1.7.1) (2026-08-02)


### Bug Fixes

* **ci:** queue staging deploys instead of cancelling them ([#260](https://github.com/adanalife/website/issues/260)) ([4fa7c3f](https://github.com/adanalife/website/commit/4fa7c3f2c084183d5d880ad329e42cc8b089ca95))
