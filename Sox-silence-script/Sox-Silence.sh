#!/bin/bash

echo "archivo de entrada = $1"
echo "archivo de salida = $2"
dd bs=5000 count=1 if=/dev/zero | sox -t raw -v 0 -c2 -b8 -eunsigned-integer -r 250k - -t raw - > $2
cat $1 >> $2
dd bs=5000 count=1 if=/dev/zero | sox -t raw -v 0 -c2 -b8 -eunsigned-integer -r 250k - -t raw - >> $2
