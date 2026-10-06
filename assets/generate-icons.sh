#!/bin/sh
# Regenerates the launcher icon PNG from assets/launcher_icon.svg.
#
# Run from the repository root:
#
#     sh assets/generate-icons.sh
#
# The artwork is black on transparent; it is refilled white, the app list
# being dark. 65x65 is what fenix847mm asks for; a device wanting another
# size scales it and warns at build time.
#
# Needs rsvg-convert (librsvg).

set -e

sed -e 's|<path |<path fill="#FFFFFF" |g' assets/launcher_icon.svg \
    | rsvg-convert -w 65 -h 65 -b none -o resources/drawables/launcher_icon.png

echo "Icon regenerated."
