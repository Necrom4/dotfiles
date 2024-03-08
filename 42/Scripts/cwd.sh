#!/bin/bash

# text=$(/usr/bin/grep -o '"/Users/dferreir/42/Cursus/[^"]*":{"tags":"current"' ~/.config/vifm/vifminfo.json)
# path=$(echo "$text" | /usr/bin/cut -d '"' -f 2)
# echo $path

text=$(/usr/bin/grep -o '"c":{[^}]*' ~/.config/vifm/vifminfo.json)
path=$(echo "$text" | awk -F'"' '{print substr($6, 1)"/"}')
echo $path
