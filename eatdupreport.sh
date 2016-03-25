#!/bin/bash 
#
# -- eat the "runcheckdupnames.txt" report created by an Arcsight ESM upgrade failure
#    and spit out queries to fix the problem and move on with life
#      - this keeps the newer resource record..
#      - this assumes report is in /opt/arcsight/upgradelogs/
#	 unless you put the name/path of one on command line
#
#	v 0.2 - added the password decrypt stuff from the rundup check
#
# david switzer  -- github/violentlydave
# ZGF2aWQgRE9UIGUgRE9UIHN3aXR6ZXIgQVRUVHR0IEdNYUlsIGRhd3QgQ09NCg== - 
# aGFoYSB5b3UgdXNlZCBteSB1Z2x5IHNjcmlwdAo=
#

MYSQL_HOME=/opt/arcsight/logger/current/arcsight
MANAGER=/opt/arcsight/manager
JAVAHOME=$MANAGER/jre/bin/java
MANAGER_LIB=$MANAGER/lib
properties=$MANAGER/config/server.properties

if [ ! -f "$properties" ]; then
		echo "No properties file where I expected it.. crap!"
	exit
fi

rawpassword=`cat $properties | grep dbconmanager.provider.logger.password | sed 's/dbconmanager.provider.logger.password.encrypted=//g' | tr -d '\\'`
probablypassword=`$JAVAHOME -cp $MANAGER_LIB/arcsightserver.jar com.arcsight.crypto.CryptoUtil -d $rawpassword 2>/dev/null`

if [ -z "$rawpassword" ]; then
    echo "Unable to obtain the database password."
	probablypassword=" .. who am I kidding, coudln't figure out the database password .. "
fi

if [ -n "$1" ]; then
	DUPLOG=$1
else
	DUPLOG="/opt/arcsight/upgradelogs/runcheckdupnames.txt"
fi

echo "# "
echo "# first.. connect to mysql like so:"
echo "# $MYSQL_HOME/bin/mysql -uarcsight arcsight -p"
echo "#  .. I think the password is $probablypassword ... but not sure.."
echo "#"
echo "# now you copy paste the queries! YOU COPY PASTE!"
CHILLINS=`cat $DUPLOG | grep "id" | awk 'NR % 2 != 0' | cut -d \: -f 2 | cut -d " " -f 1`

echo "# now baleete the newer chillins.."
for CHILL in $CHILLINS; do
	echo DELETE FROM arc_resource WHERE id = \'$CHILL\'\;
done

echo "# now commit (yourself?)"
echo COMMIT\;
echo "# ok I love you byebye!"
echo QUIT\;
