#!/bin/bash

# environment setup
REPO_PATH=/home/source/qaep.repo
GITWEB_PATH=/home/source/qaep
ROOT_DIR=/home/source/mirror_cmd

# clean up temp files
rm -f $ROOT_DIR/qaep.list.tmp
rm -f $ROOT_DIR/qaep.list.yesterday
rm -f $ROOT_DIR/qaep.list.difference

# get gitweb list
wget --quiet --no-check-certificate -O $ROOT_DIR/qaep.list.tmp https://www.codeaurora.org/gitweb/quic/la/?a=project_index
size=`stat -c %s $ROOT_DIR/qaep.list.tmp`

# get again if size is too small 
if [ $size -lt 1024 ]; then
  echo "List too small, might be error, check again."
  rm $ROOT_DIR/qaep.list.tmp
  wget --quiet --no-check-certificate -O $ROOT_DIR/qaep.list.tmp https://www.codeaurora.org/gitweb/quic/la/?a=project_index
  size=`stat -c %s $ROOT_DIR/qaep.list.tmp`
fi

if [ $size -lt 1024 ]; then
  echo "Error getting gitweb list."
else
  mv $ROOT_DIR/qaep.list $ROOT_DIR/qaep.list.yesterday
  cat $ROOT_DIR/qaep.list.tmp | sort | uniq > $ROOT_DIR/qaep.list
  rm $ROOT_DIR/qaep.list.tmp

  diff $ROOT_DIR/qaep.list $ROOT_DIR/qaep.list.yesterday > $ROOT_DIR/qaep.list.difference
  size=$(stat -c %s $ROOT_DIR/qaep.list.difference)

  if [ $size = 0 ]; then
    echo "No new repo"
  else
    echo "Updating manifest.xml"

cat << EOF > $ROOT_DIR/manifest.xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote  name="korg"
           fetch="git://codeaurora.org/" />
  <default revision="master"
           remote="korg" />

EOF
    awk -F.git '{ print "<project name=\""$1"\" />" }' $ROOT_DIR/qaep.list >> $ROOT_DIR/manifest.xml
    echo "" >> $ROOT_DIR/manifest.xml
    echo "</manifest>" >> $ROOT_DIR/manifest.xml
    
    cp $ROOT_DIR/manifest.xml $REPO_PATH/.repo/manifest.xml
    cp $ROOT_DIR/qaep.list $GITWEB_PATH/project.list      
  fi
fi

rm -f $ROOT_DIR/qaep.list.tmp
rm -f $ROOT_DIR/qaep.list.difference
