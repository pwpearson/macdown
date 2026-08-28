#!/bin/bash
set -e

# System Ruby 2.6's pinned ffi (1.14.2) segfaults on macOS Darwin 25, so we use
# the Homebrew CocoaPods (Ruby 4.0) instead. It only needs a modern ffi with a
# working native extension, which the arm64-darwin prebuilt gem provides.

cd "$(dirname "${BASH_SOURCE[0]}")"

/opt/homebrew/opt/ruby/bin/gem install ffi --user-install --no-document
/opt/homebrew/bin/pod install
