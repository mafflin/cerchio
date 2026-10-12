#!/usr/bin/env python3
"""Flatten an RGBA PNG's alpha to on/off, stdin to stdout.

For the 24px MIP icons: the watch's own flattening is poor.
"""

import struct
import sys
import zlib

# Under half, so 2px strokes keep both sides. 128 broke the alarm and phone;
# below ~96 the bell's feet merge into its ring.
CUTOFF = 112


def read_rgba(data):
    position, stream, width, height = 8, b"", None, None

    while position < len(data):
        length = struct.unpack(">I", data[position:position + 4])[0]
        kind = data[position + 4:position + 8]
        chunk = data[position + 8:position + 8 + length]

        if kind == b"IHDR":
            width, height, depth, color = struct.unpack(">IIBB", chunk[:10])
            if (depth, color) != (8, 6):
                sys.exit("flatten-alpha: expected 8 bit RGBA, got depth %d"
                         " type %d" % (depth, color))
        elif kind == b"IDAT":
            stream += chunk

        position += 12 + length

    raw = zlib.decompress(stream)
    stride = width * 4
    rows = []
    previous = bytearray(stride)
    position = 0

    # rsvg-convert may use any of the five row filters.
    for _ in range(height):
        method = raw[position]
        position += 1
        row = bytearray(raw[position:position + stride])
        position += stride

        for x in range(stride if method else 0):
            left = row[x - 4] if x >= 4 else 0
            above = previous[x]
            corner = previous[x - 4] if x >= 4 else 0

            if method == 1:
                row[x] = (row[x] + left) & 0xFF
            elif method == 2:
                row[x] = (row[x] + above) & 0xFF
            elif method == 3:
                row[x] = (row[x] + ((left + above) >> 1)) & 0xFF
            elif method == 4:
                estimate = left + above - corner
                near = (abs(estimate - left), abs(estimate - above),
                        abs(estimate - corner))
                nearest = (left, above, corner)[near.index(min(near))]
                row[x] = (row[x] + nearest) & 0xFF
            else:
                sys.exit("flatten-alpha: unknown row filter %d" % method)

        rows.append(row)
        previous = row

    return width, height, rows


def flatten(width, rows):
    out = bytearray()

    for row in rows:
        out.append(0)  # no filter

        for x in range(width):
            if row[x * 4 + 3] >= CUTOFF:
                out += b"\xFF\xFF\xFF\xFF"
            else:
                out += b"\x00\x00\x00\x00"

    return bytes(out)


def chunk(kind, payload):
    return (struct.pack(">I", len(payload)) + kind + payload
            + struct.pack(">I", zlib.crc32(kind + payload) & 0xFFFFFFFF))


def main():
    width, height, rows = read_rgba(sys.stdin.buffer.read())

    sys.stdout.buffer.write(
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
        + chunk(b"IDAT", zlib.compress(flatten(width, rows), 9))
        + chunk(b"IEND", b""))


if __name__ == "__main__":
    main()
