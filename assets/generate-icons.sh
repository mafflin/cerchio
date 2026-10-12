#!/bin/sh
# Regenerates the icon PNGs from assets/icons/*.svg. Run from the repo root.
# Paths are refilled white; the face tints them. Small set (MIP) is
# flattened, large set (AMOLED) is not. Needs rsvg-convert and python3.

set -e

SRC=assets/icons
SMALL=resources/drawables
LARGE=resources-large-icons/drawables
FLATTEN=assets/flatten-alpha.py

# Degrees clockwise, wind only
TURN=

#   $1 source svg   $2 viewBox
artwork() {
    sed -e "s|<path |<path fill=\"#FFFFFF\" ${TURN:+transform=\"rotate($TURN 12 12)\" }|g" \
        -e "s|viewBox=\"[^\"]*\"|viewBox=\"$2\"|" \
        "$SRC/$1"
}

#   $1 source svg   $2 destination png   $3 width   $4 height   $5 viewBox
#   $6 "flat" to flatten the alpha
render() {
    mkdir -p "$(dirname "$2")"

    if [ "$6" = "flat" ]; then
        artwork "$1" "$5" \
        | rsvg-convert -w "$3" -h "$4" -b none \
        | python3 "$FLATTEN" > "$2"
    else
        artwork "$1" "$5" | rsvg-convert -w "$3" -h "$4" -b none -o "$2"
    fi
}

BOX="0 0 24 24"

#   $1 source svg   $2 path under drawables
pair() {
    render "$1" "$SMALL/$2" 24 24 "$BOX" flat
    render "$1" "$LARGE/$2" 36 36 "$BOX"
}

pair alarm.svg alarm/alarm.png
pair phone.svg phone/phone.png
pair recovery.svg recovery/recovery.png

for level in 0 10 20 30 40 50 60 70 80 90 100; do
    pair "battery/$level.svg" "battery/battery_$level.png"
done

# Named for where the wind comes from; the art points north.
for direction in "n 180" "ne 225" "e 270" "se 315" "s 0" "sw 45" "w 90" "nw 135"; do
    set -- $direction
    TURN=$2
    pair wind/bearing.svg "wind/wind_$1.png"
done
TURN=

pair wind/calm.svg wind/wind_calm.png

# Cropped to the letters. The small box puts every stem edge on a whole pixel
# at scale 1.5, so the flattened stems come out even.
MERIDIEM_SMALL="1 5 22 14"
MERIDIEM_LARGE="1.684 5.684 20.632 12.632"

render meridiem/am.svg "$SMALL/meridiem/am.png" 33 21 "$MERIDIEM_SMALL" flat
render meridiem/pm.svg "$SMALL/meridiem/pm.png" 33 21 "$MERIDIEM_SMALL" flat
render meridiem/am.svg "$LARGE/meridiem/am.png" 49 30 "$MERIDIEM_LARGE"
render meridiem/pm.svg "$LARGE/meridiem/pm.png" 49 30 "$MERIDIEM_LARGE"

# Sized to stand beside FONT_TINY digits
render sun/sunrise.svg "$SMALL/sun/sunrise.png" 24 24 "$BOX" flat
render sun/sunrise.svg "$LARGE/sun/sunrise.png" 32 32 "$BOX"
render sun/sunset.svg "$SMALL/sun/sunset.png" 24 24 "$BOX" flat
render sun/sunset.svg "$LARGE/sun/sunset.png" 32 32 "$BOX"
render sun/zenith.svg "$SMALL/sun/zenith.png" 24 24 "$BOX" flat
render sun/zenith.svg "$LARGE/sun/zenith.png" 32 32 "$BOX"

# Same sizes as the suns
field() {
    render "$1" "$SMALL/field/$2.png" 24 24 "$BOX" flat
    render "$1" "$LARGE/field/$2.png" 32 32 "$BOX"
}

field battery/100.svg battery
field cal.svg calories
field steps.svg steps
field timer.svg timer
field altitude.svg altitude
field notifications.svg notifications
field heart.svg heart
field run.svg run
field bike.svg bike
field recovery.svg recovery
field human.svg human
field thermometer.svg thermometer

# Material Design Icons (Apache 2.0), @mdi/svg 7.4.47, weather- prefix dropped
for name in \
    sunny night partly-cloudy night-partly-cloudy cloudy \
    rainy pouring partly-rainy snowy snowy-heavy partly-snowy \
    snowy-rainy partly-snowy-rainy lightning-rainy lightning partly-lightning \
    hail windy windy-variant fog hazy dust smoke volcano snowflake \
    tornado hurricane hurricane-outline cloud-question unknown; do
    field "weather/$name.svg" "weather/$name"
done

# Never tinted, and scaled by the system, so not flattened. 65px: fenix847mm.
render launcher_icon.svg "$SMALL/launcher_icon.png" 65 65 "$BOX"

echo "Icons regenerated."
