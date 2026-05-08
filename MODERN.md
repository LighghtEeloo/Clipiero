# Modernization Notes

Clipy is old software that still does a useful job. Our goal is to keep the basic clipboard workflow working on current macOS, not to redesign the app or add features.

Patch in small pieces. Broad PRs that mix runtime fixes, dependency changes, and product decisions should be split before adoption.

What to watch:

- Pasteboard: normalize modern UTI types such as `public.tiff`, `public.utf8-plain-text`, `public.rtf`, `com.adobe.pdf`, and `public.url` to Clipy's stored legacy types.
- macOS support: the supported floor is Apple Silicon on macOS 13 Ventura. Future support changes should update README, Podfile, CI, and Xcode settings together.
- Build tooling: refresh Bundler, CocoaPods, and generated Pods as one reproducible setup.
- Tests: keep Quick/Nimble wired, or migrate the test suite completely.
- Login items: use `SMAppService.mainApp` and preserve existing preferences as the source of truth for whether launch-at-login is enabled.
- Updates: keep Sparkle preferences visible unless Sparkle is intentionally removed or replaced.
- Dark mode: prefer system colors where fixed colors break readability. Verify the main windows by eye.
- CI: add build and test checks so maintenance patches prove themselves before merge.
