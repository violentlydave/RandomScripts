#!/bin/bash
#
#  -- attempt to make a 1 page summary out of burp report for 
#	quick viewing/report writing
#
# david switzer  -- github/violentlydave
# ZGF2aWQgRE9UIGUgRE9UIHN3aXR6ZXIgQVRUVHR0IEdNYUlsIGRhd3QgQ09NCg== - 
# aGFoYSB5b3UgdXNlZCBteSB1Z2x5IHNjcmlwdAo=


if [ "$1" == "" ]; then 
	echo "$0 -- Create single page summary of Burp HTML report"; echo ""
	echo " usage:"
	echo " $0 name_of_burp_htmlreport.html"; echo ""
	exit
fi

REPORT=$1
REPORTOUTPUT="summarized_output_$REPORT"
REPORTFINALOUTPUT="summarized_$REPORT"
#	grab name of site, oly check first 2k lines in case report is huge
NAME=`head -2000 $REPORT | grep TOCH1 | dos2unix | cut -d \; -f 2 | grep -i http | cut -d \/ -f 3 | sort | uniq | head -1`
#echo WE ALREADY DID THIS lynx -dump $REPORT > $REPORTOUTPUT
lynx -dump $REPORT > /tmp/tmpoutputmeme

REPORTOUTPUT=/tmp/tmpoutputmeme

# title
#
echo "<pre>" > $REPORTFINALOUTPUT
echo "--------------------------------------------" >> $REPORTFINALOUTPUT
echo " summarized burps for $NAME" >> $REPORTFINALOUTPUT
echo "--------------------------------------------" >> $REPORTFINALOUTPUT
echo "              " >> $REPORTFINALOUTPUT

# summary# now we get tricky
#
#       2nd "Severity High" = end of summary, so we want the lines before that:
#expr `cat SOMEONE_report_dump.txt |  grep -n "Severity High" | sed 's/^\([0-9]\+\):.*$/\1/' | head -2 | tail -1` - 1

SEVHIGH=`cat $REPORTOUTPUT |  grep -n "Severity High" | sed 's/^\([0-9]\+\):.*$/\1/' | head -2 | tail -1`
head -$SEVHIGH $REPORTOUTPUT | dos2unix  | sed "s/Severity High$/----/g" >> $REPORTFINALOUTPUT

# now - summarize the type of vulns:
echo "--------------------------------------------" >> $REPORTFINALOUTPUT
echo "  .. main types of vulns, yo." >> $REPORTFINALOUTPUT
echo "--------------------------------------------" >> $REPORTFINALOUTPUT

grep "\][1234567890]*\.\ " $REPORTOUTPUT | dos2unix | sed "s/\[[1234567890]*\]//g" >> $REPORTFINALOUTPUT

