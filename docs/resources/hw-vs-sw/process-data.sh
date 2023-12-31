#/bin/sh

python preprocess.py < performance-sw-only.txt | jq > performance-sw-only.json

python preprocess.py < performance-hw-acc.txt | jq 'map(. + {"Rotation time": (((.["Kernel execution"][:-2] | tonumber) + (.["Total transfer time"][:-2] | tonumber)) | tostring + "us")})' > performance-hw-acc.json


./stats.sh "Convert to BW" performance-hw-acc.json > performance-hw-acc-stats-convert.json
./stats.sh "Convert to BW" performance-sw-only.json > performance-sw-only-stats-convert.json

./stats.sh "Capture frame" performance-hw-acc.json > performance-hw-acc-stats-capture.json
./stats.sh "Capture frame" performance-sw-only.json > performance-sw-only-stats-capture.json

./stats.sh "Rotation time" performance-hw-acc.json > performance-hw-acc-stats-rotation.json
./stats.sh "Rotation time" performance-sw-only.json > performance-sw-only-stats-rotation.json