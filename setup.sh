#!/bin/bash 
cleanup(){
  set -x
  rm -f cachenote_german.txt geocachenote.txt
  set +x
}

PATCHDIR="./patches"
COMMON="./common"

LOGO_DL_1="http://www.treasuresofthemountains.eu/images/Geocaching_Logo.jpg"
LOGO_DL_2="http://www.deviantart.com/download/57016206/GeoCaching_com__s_Logo_by_shinaz.gif"

if [ ! -f "$(which wget)" ]; then
  echo "Please install wget into PATH"
  cleanup
  exit 1
fi
echo fetching official disclaimers...
wget -nv -c -O- http://www.geocaching.com/articles/cachenote_german.txt | iconv -f ISO_8859-15 -t utf-8 > cachenote_german.txt
if [[ $? != 0 ]]; then
  echo wget returned an error
  cleanup
  exit 1
fi
wget -nv -c -O- http://www.geocaching.com/articles/geocachenote.txt | iconv -f ISO_8859-15 -t utf-8 > geocachenote.txt
if [[ $? != 0 ]]; then
  echo wget returned an error
  cleanup
  exit 1
fi
patch cachenote_german.txt < $PATCHDIR/cachenote_german.patch
if [[ $? != 0 ]]; then
  echo patch failed
  cleanup
  exit 1
fi
patch geocachenote.txt < $PATCHDIR/cachenote_english.patch
if [[ $? != 0 ]]; then
  echo patch failed
  cleanup
  exit 1
fi
mv cachenote_german.txt $COMMON/cachenote_german.tex
if [[ $? != 0 ]]; then
  echo renaming via mv failed
  cleanup
  exit 1
fi
mv geocachenote.txt $COMMON/cachenote_english.tex
if [[ $? != 0 ]]; then
  echo renaming via mv failed
  :cleanup
  exit 1
fi

echo fetching large-sized gc.com logos...
wget -nv -c $LOGO_DL_1 -O $COMMON/Geocaching_Logo.jpg
if [[ $? != 0 ]]; then
  echo wget returned an error, trying different logo...
  wget -nv -c $LOGO_DL_2 -O $COMMON/Geocaching_Logo.jpg
  if [[ $? != 0 ]]; then
    cleanup
    exit 1
  fi
fi

