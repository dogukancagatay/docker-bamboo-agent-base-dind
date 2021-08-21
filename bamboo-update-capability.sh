#!/bin/sh
# COPY FROM https://bitbucket.org/atlassian/bamboo-update-capability/raw/master/bamboo-update-capability.sh
set -eu

displayUsage() {
	echo "\nScript to upgrade bamboo agent capabilities directly in properties file"
	echo "Will remove from file old property with given name and write a new one"
	echo "\nUsage: $(basename "$0") capability value [file.properties]"
	echo "\n  capability - capabaliyty name"
	echo "  value - value of capability"
	echo "  file.properties - optional path to properties file (default: ~/bamboo-agent-home/bamboo-capabilities.properties)\n"
}

if [  $# -le 1 ]; then
	displayUsage
	exit 1
fi

if [ $# -le 2 ]; then
	propertiesFilePath=${BAMBOO_USER_HOME}/init-bamboo-capabilities.properties
else
	propertiesFilePath=$3
fi

#create file if missing
if [ ! -f $propertiesFilePath ]; then
  dir=$(dirname ${propertiesFilePath})
  mkdir -p ${dir}
  touch $propertiesFilePath
fi

#escaping ' ', '=' and '\'
name=$(echo $1 | sed -e 's/\\/\\\\\\\\/g' -e 's/ /\\ /g' -e 's/=/\\=/g' )
value=$(echo $2 | sed -e 's/\\/\\\\\\\\/g' -e 's/ /\\ /g' -e 's/=/\\=/g')
#remove previous values of this key
nameToRemove=$(echo $name | sed -e 's/\\/\\\\/g')
sed -e "/^$nameToRemove=/d" -i $propertiesFilePath
#add new value of this key
echo $name=$value >> $propertiesFilePath
