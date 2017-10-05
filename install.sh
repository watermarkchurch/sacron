#! /bin/bash

cp sacron_service /etc/init.d/sacron
chown root:root /etc/init.d/sacron
cp sacron.sh /bin/sacron

cd sunwait-20041208
make
cp sunwait /bin/sunwait

service sacron start