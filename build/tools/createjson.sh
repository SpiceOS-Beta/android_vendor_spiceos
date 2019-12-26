#!/bin/bash
#
# Copyright (C) 2020 SpiceOS
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#$1=TARGET_DEVICE, $2=PRODUCT_OUT, $3=LINEAGE_VERSION
existingOTAjson=./packages/apps/Updater_Db/$1.json
output=$2/$1.json

#cleanup old file
if [ -f $output ]; then
	rm $output
fi

if [ -f $existingOTAjson ]; then
	#get data from already existing device json
	#there might be a better way to parse json yet here we try without adding more dependencies like jq
	maintainer=`grep -n "maintainer" $existingOTAjson | cut -d ":" -f 3 | sed 's/"//g' | sed 's/,//g' | xargs`
	oem=`grep -n "oem" $existingOTAjson | cut -d ":" -f 3 | sed 's/"//g' | sed 's/,//g' | xargs`
	device=`grep -n "device" $existingOTAjson | cut -d ":" -f 3 | sed 's/"//g' | sed 's/,//g' | xargs`
	filename=$3
	version=`echo "$3" | cut -d'-' -f2`
	download="https://sourceforge.net/projects/spiceos/files/11/'$device'/'$4'/download"
	buildprop=$2/system/build.prop
	linenr=`grep -n "ro.system.build.date.utc" $buildprop | cut -d':' -f1`
	timestamp=`sed -n $linenr'p' < $buildprop | cut -d'=' -f2`
	md5=`md5sum "$2/$3" | cut -d' ' -f1`
	size=`stat -c "%s" "$2/$3"`
	buildtype=`grep -n "type" $existingOTAjson | cut -d ":" -f 3 | sed 's/"//g' | sed 's/,//g' | xargs`
	forum=`grep -n "\"forum\"" $existingOTAjson | cut -d ":" -f 4 | sed 's/"//g' | sed 's/,//g' | xargs`
	if [ ! -z "$forum" ]; then
		forum="https:"$forum
	fi
	gapps=`grep -n "\"gapps\"" $existingOTAjson | cut -d ":" -f 4 | sed 's/"//g' | sed 's/,//g' | xargs`
	if [ ! -z "$gapps" ]; then
		gapps="https:"$gapps
	fi
	firmware=`grep -n "\"firmware\"" $existingOTAjson | cut -d ":" -f 4 | sed 's/"//g' | sed 's/,//g' | xargs`
	if [ ! -z "$firmware" ]; then
		firmware="https:"$firmware
	fi
	modem=`grep -n "\"modem\"" $existingOTAjson | cut -d ":" -f 4 | sed 's/"//g' | sed 's/,//g' | xargs`
	if [ ! -z "$modem" ]; then
		modem="https:"$modem
	fi
	bootloader=`grep -n "\"bootloader\"" $existingOTAjson | cut -d ":" -f 4 | sed 's/"//g' | sed 's/,//g' | xargs`
	if [ ! -z "$bootloader" ]; then
		bootloader="https:"$bootloader
	fi
	recovery=`grep -n "\"recovery\"" $existingOTAjson | cut -d ":" -f 4 | sed 's/"//g' | sed 's/,//g' | xargs`
	if [ ! -z "$recovery" ]; then
		recovery="https:"$recovery
	fi
	paypal=`grep -n "\"paypal\"" $existingOTAjson | cut -d ":" -f 4 | sed 's/"//g' | sed 's/,//g' | xargs`
	if [ ! -z "$paypal" ]; then
		paypal="https:"$paypal
	fi
	telegram=`grep -n "\"telegram\"" $existingOTAjson | cut -d ":" -f 4 | sed 's/"//g' | sed 's/,//g' | xargs`
	if [ ! -z "$telegram" ]; then
		telegram="https:"$telegram
	fi

	echo '{
	"response": [
		{
			"maintainer": "'$maintainer'",
			"oem": "'$oem'",
			"device": "'$device'",
			"filename": "'$filename'",
			"download": "https://sourceforge.net/projects/spiceos/files/11/'$1'/'$3'/download",
			"timestamp": '$timestamp',
			"md5": "'$md5'",
			"size": '$size',
			"version": "'$version'",
			"buildtype": "'$buildtype'",
			"forum": "'$forum'",
			"gapps": "'$gapps'",
			"firmware": "'$firmware'",
			"modem": "'$modem'",
			"bootloader": "'$bootloader'",
			"recovery": "'$recovery'",
			"paypal": "'$paypal'",
			"telegram": "'$telegram'"
		}
	]
}' >> $output

else
	#if not already supported, create dummy file with info in it on how to
	echo 'There is no official support for this device yet' >> $output;
	echo 'Consider adding official support by reading the documentation at https://github.com/SpiceOS/android_packages_apps_Updater_Db/blob/11/README.md' >> $output;
fi

echo "JSON file data for OTA support is at: '$2'/'$device'.json"
cat $output
echo ""
