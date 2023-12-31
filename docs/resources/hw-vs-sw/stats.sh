#!/bin/sh

jq 'group_by(.Rotation) | map({
Rotation: .[0].Rotation,
MinTime: (map(.["'"$1"'"][:-2] | tonumber) | min),
MaxTime: (map(.["'"$1"'"][:-2] | tonumber) | max),
MedianTime: (map(.["'"$1"'"][:-2] | tonumber) | sort | if length % 2 == 0 then (.[length/2-1] + .[length/2]) / 2 else .[length/2] end),
AverageTime: (map(.["'"$1"'"][:-2] | tonumber) | add / length)
})' "$2"
