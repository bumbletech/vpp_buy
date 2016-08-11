#!/bin/bash
# Written by Brad Schmidt in a hurry. @bradschm
# Updated by Josh Bourdon in less of a hurry, but still a hurry. @joshbourdon
# Provide App URLs in a text file (name on last line)
# Put in the apple id and password below.
# TEST TEST TEST - This was used with Google Chrome back in August 2016. Tab counts and fields may have changed!
# A log is produced and a screen shot of the purchase screen is captured.
# CSV based log added with purchased/failed status based on expected confirmation URL
# Script injects volume link into the URL to save some time and tabs

# Go buy (Free?) VPP apps - May work with paid

#osascript -e 'tell application "System Events" to keystroke "username"';
#osascript -e 'tell application "System Events" to keystroke tab';
#osascript -e 'tell application "System Events" to delay 3.0';
#osascript -e 'tell application "System Events" to keystroke return';
#osascript -e 'tell application "System Events" to delay 3.0';

# Logging -- Each URL is logged to $LOGFILE 
# A screenshot is taken on each purchase with a date, the App URL will be in a text file with the same name 
LOGFILE=VPPbuy.log

# Start a new section of the log
/bin/echo "-------------------------------New Run------------------------------" >> $LOGFILE
/bin/date "+%Y-%m-%d %H:%M:%S: VPP Purchase started" >> $LOGFILE

jscPath="/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc"


OLDIFS=$IFS
IFS=","
while read app_url app_count
do

adam_id=`echo $app_url | awk -F'\/id|\\\?mt' '{print $2}'`
re='^[0-9]+$'
if ! [[ $adam_id =~ $re ]] ; then
	adam_id=`echo $app_url | awk -F'\/id|\\\?mt' '{print $3}'`
fi

echo "adam id is $adam_id"
echo "app count is $app_count"

itunes_api_url="http://itunes.apple.com/lookup?id=${adam_id}"
echo "api url is $itunes_api_url"
curl -s "$itunes_api_url" > /tmp/result.txt
result="/tmp/result.txt"

json=`cat $result`

trackName=`$jscPath -e "var json = $json; json['results'].forEach(function(result) { print(result['trackName']) });"`
bundleId=`$jscPath -e "var json = $json; json['results'].forEach(function(result) { print(result['bundleId']) });"`

app_log_name="$trackName $bundleId"

#injects volume url to app link
volumestring="volume.itunes.apple.com"
volume_url="${app_url/itunes.apple.com/$volumestring}"

# open google chrome
open /Applications/Google\ Chrome.app 
sleep 1;

# open VPP Store
osascript -e 'tell application "System Events" to keystroke "l" using command down'
text='https://volume.itunes.apple.com/us/store'
osascript <<EOF
tell application "System Events" to keystroke "$volume_url"
EOF
osascript -e 'tell application "System Events" to keystroke return';
sleep 3;

#Tab * 16
COUNTER=0
TABS=17
         while [  $COUNTER -lt $TABS ]; do
			osascript -e 'tell application "System Events" to keystroke tab';
			osascript -e 'tell application "System Events" to delay 0.2';
            let COUNTER=COUNTER+1 
         done
sleep 1;
#25
#the number of apps you want to get
text=$app_count
osascript <<EOF
tell application "System Events" to keystroke "$text"
EOF
#Tab
osascript -e 'tell application "System Events" to keystroke tab';
#Tab
osascript -e 'tell application "System Events" to keystroke tab';

#Enter
osascript -e 'tell application "System Events" to keystroke return';
sleep 2;
#Tab * 17
COUNTER=0
TABS=2
         while [  $COUNTER -lt $TABS ]; do
			osascript -e 'tell application "System Events" to keystroke tab';
			osascript -e 'tell application "System Events" to delay 0.2';
            let COUNTER=COUNTER+1 
         done
#Enter
osascript -e 'tell application "System Events" to keystroke return';
sleep 2;
#Apple ID )
text=yourappleid@domain.org
osascript <<EOF
tell application "System Events" to keystroke "$text"
EOF
#Tab
osascript -e 'tell application "System Events" to keystroke tab';

#Password 
text=yourpassword
osascript <<EOF
tell application "System Events" to keystroke "$text"
EOF
#Enter
osascript -e 'tell application "System Events" to keystroke return';
sleep 6;
#check chrome for the current URL
current_url=$(osascript <<EOF
tell application "Google Chrome"
	activate
	tell application "System Events"
		tell application process "Google Chrome"
			get value of text field 1 of toolbar 1 of window 1
		end tell
	end tell
end tell
EOF)

#currently known beginning of completed purchase URL
finished_url="https://volume.itunes.apple.com/WebObjects/MZStore.woa/wa/orderComplete?buy"

#check if URL matches for improved logging
if [[ "$current_url" == "$finished_url"* ]]; then
	purchase_status="purchased"
else
	purchase_status="failed"
fi

#Enter
# Logging
/usr/sbin/screencapture `date '+%H-%M-%S'`_${trackName}_${bundleId}_${purchase_status}.png
/bin/echo "$trackName $bundleId $volume_url" > `date '+%H-%M-%S'`_${trackName}_${bundleId}_${purchase_status}.txt
/bin/date "+%Y-%m-%d %H:%M:%S: $trackName $bundleId $volume_url $purchase_status." >> $LOGFILE
/bin/date "+%Y-%m-%d %H:%M:%S,$bundleId,$volume_url,$purchase_status" >> VPP_Purchase_Log.csv
sleep 1;

done < appurlsvppbuy.txt
