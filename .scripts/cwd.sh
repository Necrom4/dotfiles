#!/bin/bash

# text=$(/usr/bin/grep -o '"/root/[^"]*":{"tags":"current"' ~/.vifm/vifminfo.json)
# path=$(echo "$text" | /usr/bin/cut -d '"' -f 2)
# echo $path

text=$(/usr/bin/grep -o '"c":{[^}]*' ~/.vifm/vifminfo.json)
path=$(echo "$text" | awk -F'"' '{print substr($6, 1)"/"}')
echo $path
