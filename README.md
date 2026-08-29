# MacDown

[![](https://img.shields.io/github/release/MacDownApp/macdown.svg)](http://macdown.uranusjr.com/download/latest/)
![Total downloads](https://img.shields.io/github/downloads/MacDownApp/macdown/latest/total.svg)
[![Build Status](https://travis-ci.org/MacDownApp/macdown.svg?branch=master)](https://travis-ci.org/MacDownApp/macdown)


MacDown is an open source Markdown editor for OS X, released under the MIT License. The author stole the idea from [Chen Luo](https://twitter.com/chenluois)’s [Mou](http://mouapp.com) so that people can make crappy clones.

Visit the [project site](http://macdown.uranusjr.com/) for more information, or download [MacDown.app.zip](http://macdown.uranusjr.com/download/latest/) directly from the [latest releases](https://github.com/MacDownApp/macdown/releases/latest) page.

## Fork Notes

This fork adds live preview refresh on external file changes, plus the build adjustments needed to compile on Apple Silicon with a current Xcode and Ruby toolchain. These changes live on the `feature/auto-refresh-on-external-change` branch so they can be rebased onto future upstream releases. The feature itself is isolated in its own commit (`MPDocument.m`, `MainMenu.xib`), separate from the build-enablement commit, so it can be carried forward independently.

### Live Preview Refresh on External Changes

MacDown re-renders the open document when its file is modified by another application, without closing and reopening the window. This helps when the Markdown is produced or edited by an external tool such as a script, another editor, or a git operation.

* When the file changes on disk and the document has no unsaved edits, the editor and preview reload automatically.
* When the document has unsaved edits, MacDown prompts before overwriting them, offering **Reload** (discard local edits) or **Keep My Changes**. This prevents silent loss of work.
* A per-window toggle, **File > Auto-Refresh on External Changes**, enables or disables the behavior. It is on by default, and disabled for a new document that has no file on disk yet.

Implementation: `MPDocument` overrides `presentedItemDidChange`, available because `NSDocument` already conforms to `NSFilePresenter`, and performs a coordinated read through `NSFileCoordinator`. See `MacDown/Code/Document/MPDocument.m`.

### Building on Apple Silicon / Modern Xcode

The upstream setup steps assume an older toolchain. On an arm64 Mac with a current Xcode, two problems block a clean build:

* The `ffi` gem pinned in `Gemfile.lock` (1.14.2) crashes with a Bus Error on macOS Darwin 25, so the Bundler-managed CocoaPods cannot run.
* The vendored Sparkle 1.18.1 is x86_64-only and fails to link against an arm64 build.

This fork resolves both:

* Use the Homebrew CocoaPods (Ruby 4.0) with a modern `ffi` that has a working arm64 native extension, instead of the pinned toolchain. The helper script `install_gems.sh` installs that `ffi` and runs `pod install`.
* `Podfile` bumps Sparkle to `~> 1.27`, a universal binary with an arm64 slice, and raises the platform to 10.13, which Sparkle 1.27 requires.
* `MacDown.xcodeproj` raises the deployment target to 11.0, uses ad-hoc code signing for local builds, and disables user script sandboxing so the resource-copy build phases (for example "Fetch Prism Resources") can run.

Setup on this configuration, from the repository root:

    git submodule update --init
    ./install_gems.sh
    make -C Dependency/peg-markdown-highlight

then open `MacDown.xcworkspace` and build. The `prism` submodule must be initialised by the first command, or the "Fetch Prism Resources" build phase fails with a missing-source error.

### Running Alongside the Release App

The Debug build uses the bundle identifier `com.uranusjr.macdown-debug`, distinct from the released `com.uranusjr.macdown`, so both can run at the same time. They share the display name "MacDown", so to tell them apart in the Dock and Finder, install the Debug build under a different name: build in Xcode, copy the product from DerivedData to `/Applications/MacDown Dev.app`, set its `CFBundleName` and `CFBundleDisplayName` to "MacDown Dev", and re-sign ad-hoc with `codesign --force --deep --sign -`. This is a local convenience and is intentionally not part of the Xcode project, since renaming the product there would break the test target's hard-coded `MacDown.app` paths.

## Install

[Download](http://macdown.uranusjr.com/download/latest/), unzip, and drag the app to Applications folder. MacDown is also available through [Homebrew Cask](https://caskroom.github.io/):

    brew install --cask macdown

## Screenshot

![screenshot](assets/screenshot.png)

## License

MacDown is released under the terms of MIT License. You may find the content of the license [here](http://opensource.org/licenses/MIT), or inside the `LICENSE` directory.

You may find full text of licenses about third-party components in the `LICENSE` directory, or the **About MacDown** panel in the application.

The following editor themes and CSS files are extracted from [Mou](http://mouapp.com), courtesy of Chen Luo:

* Mou Fresh Air
* Mou Fresh Air+
* Mou Night
* Mou Night+
* Mou Paper
* Mou Paper+
* Tomorrow
* Tomorrow Blue
* Tomorrow+
* Writer
* Writer+
* Clearness
* Clearness Dark
* GitHub
* GitHub2

## Development

### Requirements

If you wish to build MacDown yourself, you will need the following components/tools:

* OS X SDK (10.14 or later)
* Git
* [Bundler](http://bundler.io)

> Note: Old versions of CocoaPods are not supported. Please use Bundler to execute CocoaPods, or make sure your CocoaPods is later than shown in `Gemfile.lock`.

> Note: The Command Line Tools (CLT) should be unnecessary. If you failed to compile without it, please install CLT with
>
>     xcode-select --install
>
> and report back.

An appropriate SDK should be bundled with Xcode 5 or later versions.

### Environment Setup

After cloning the repository, run the following commands inside the repository root (directory containing this `README.md` file):

    git submodule update --init
    bundle install
    bundle exec pod install
    make -C Dependency/peg-markdown-highlight

and open `MacDown.xcworkspace` in Xcode. The first command initialises the dependency submodule(s) used in MacDown; the second one installs dependencies managed by CocoaPods.

Refer to the official guides of Git and CocoaPods if you need more instructions. If you run into build issues later on, try running the following commands to update dependencies:

    git submodule update
    bundle exec pod install

### Translation

Please help translation on [Transifex](https://www.transifex.com/macdown/macdown/).

![Transifex translation percentage](https://www.transifex.com/projects/p/macdown/resource/macdownxliff/chart/image_png/)

## Discussion

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/MacDownApp/macdown)

Join our [Gitter channel](https://gitter.im/MacDownApp/macdown) if you have any problems with MacDown. Any suggestions are welcomed, too!

You can also [file an issue directly](https://github.com/MacDownApp/macdown/issues/new) on GitHub if you prefer so. But please, **search first to make sure no-one has reported the same issue already** before opening one yourself. MacDown does not update in your computer immediately when we make changes, so something you experienced might be known, or even fixed in the development version.

MacDown depends a lot on other open source projects, such as [Hoedown](https://github.com/hoedown/hoedown) for Markdown-to-HTML rendering, [Prism](http://prismjs.com) for syntax highlighting (in code blocks), and [PEG Markdown Highlight](https://github.com/ali-rantakari/peg-markdown-highlight) for editor highlighting. If you find problems when using those particular features, you can also consider reporting them directly to upstream projects as well as to MacDown’s issue tracker. I will do what I can if you report it here, but sometimes it can be more beneficial to interact with them directly.

## Tipping

If you find MacDown suitable for your needs, please consider [giving me a tip through PayPal](http://macdown.uranusjr.com/faq/#donation). Or, if you prefer to buy me a drink *personally* instead, just [send me a tweet](https://twitter.com/uranusjr) when you visit [Taipei, Taiwan](http://en.wikipedia.org/wiki/Taipei), where I live. I look forward to meeting you!

