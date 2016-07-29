#!/bin/bash
# Written by Brad Schmidt in a hurry. @bradschm
# Provide App URLs in a text file (name on last line)
# Put in the apple id and password below.
# TEST TEST TEST - This was used with Google Chrome back in March 2015. Tab counts and fields may have changed!
# A log is produced and a screen shot of the purchase screen is captured. 
# this version changes your app urls to "volume.itunes.apple.com" -- saves a few seconds per app

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

while read line
do

#injects volume url to app link
volumestring="volume.itunes.apple.com"
volume_url="${line/itunes.apple.com/$volumestring}"


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
text='100'
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
text=yourappleid@companyschool.org
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
sleep 2;
# Logging
/usr/sbin/screencapture `date '+%H-%M-%S'`.png
/bin/echo "$volume_url" > `date '+%H-%M-%S'`.txt
/bin/date "+%Y-%m-%d %H:%M:%S: $volume_url purchased." >> $LOGFILE
sleep 3;

done < appurlsvppbuy.txt
