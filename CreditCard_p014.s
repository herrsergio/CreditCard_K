#!/bin/bash

VERSION=`cat /usr/fms/op/cfg/Release`

if [ "$VERSION" = "5.3_INTERNATIONAL_SUS" ]; then
    /usr/bin/ph/phdppr /usr/fms/op/print1/p014 | cut -d'|' -f5,8 | awk -F'|' '{if($1 ~ 208 || $1 ~ 209 ) total= total+$2}; END {print total/100}'
else
    /usr/fms/op/bin/phdppr /usr/fms/op/print1/p014 | cut -d'|' -f4,7 | awk -F'|' '{if($1 ~ 208 || $1 ~ 209 ) total= total+$2}; END {print total/100}'
fi

