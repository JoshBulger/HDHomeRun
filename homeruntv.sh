#!/bin/bash

# Uses hdhomerun_config to scan for channels and then creates .strm files in ~/Videos/Live TV for XBMC streaming

# INSTALL SECTION UNTESTED - which is why it's commented out; uncomment at your own risk
# Check if you have already installed hdhomerun-config; install it if not
#if [ ! -d $(dpkg -l | grep hdhomerun-config) ]; then
#	cd /tmp
#	for j in http://download.silicondust.com/hdhomerun/libhdhomerun_20120405.tgz http://download.silicondust.com/hdhomerun/hdhomerun_config_gui_20120405.tgz
#		wget $j
#		tar xvzf hdhomerun_config_gui_20120405.tgz
#		cd hdhomerun_config_gui/
#		./configure || $( sudo apt-get install --assume-yes libgtk2.0-dev; ./configure )
#		make
#		sudo make install clean
#	done
#	#rm -rf /tmp/hdhomerun*
#fi

# Check if directory exists, if not then create it
if [ ! -d "~/Videos/Live\ TV" ]; then
	mkdir -p ~/Videos/Live\ TV
fi

# Discover device name
device=$(hdhomerun_config discover |awk '{print $3}')

# Scan channels directly into while loop - pull relevant data and create strm file
hdhomerun_config $device scan 1 | grep -vEi 'tsid|lock|none' | while read output
	do
		if [[ "$output" == "SCANNING"* ]]; then
			scan=$(echo $output | awk '{print $2}')
		fi
		if [[ "$output" == "PROGRAM"* ]]; then
			prog=$(echo $output | awk '{print $2}')
			file=$(echo $output | cut -d':' -f2)
			# Create .strm file
			echo hdhomerun://$device-1/tuner1$file\?channel\=auto\:$scan\&program\=${prog/:/} > ~/Videos/Live\ TV/"${file/\ /}".strm		
		fi
	done
exit 0
