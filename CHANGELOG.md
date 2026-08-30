# Changelog

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
