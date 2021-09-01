#!/bin/bash

FILE=/nethackathon/running
SAVE=/nethackathon/nethackdir/save/1003nethackathon.gz
NETHACKRC=/home/$USER/.nethackrc

if [ ! -f "$NETHACKRC" ]; then
        PS3='No .nethackrc found, what are your preferences?  '
        options=("Numpad + Curses" "Vi keys + Curses" "Numpad + ASCII" "Vi keys + ASCII")
        select opt in "${options[@]}"
        do
                case $opt in
                        "Numpad + Curses")
                                cp /nethackathon/nethackrc/nethackrc_curses_numpad $NETHACKRC
                                break
                                ;;
                        "Vi keys + Curses")
                                cp /nethackathon/nethackrc/nethackrc_curses_vi $NETHACKRC
                                break
                                ;;
                        "Numpad + ASCII")
                                cp /nethackathon/nethackrc/nethackrc_ascii_numpad $NETHACKRC
                                break
                                ;;
                        "Vi keys + ASCII")
                                cp /nethackathon/nethackrc/nethackrc_ascii_vi $NETHACKRC
                                break
                                ;;
                        *) echo "invalid option $REPLY";;
                esac
        done
fi

cp --preserve=ownership $NETHACKRC /home/streamer/.nethackrc

if test -f "$FILE"; then
  echo "$(cat $FILE) is currently running NetHack, ask them to save and quit."
  echo "(If you are certain this message is in error, rm /nethackathon/running)"
else
  echo "$USER (AU Server)" > $FILE
  sudo -u streamer scp $FILE streamer@uk.nethackathon.org:$FILE
  sudo -u streamer scp $FILE streamer@nethackathon.org:$FILE
  sudo -u streamer /usr/games/nethack -d /nethackathon/nethackdir -u nethackathon
  wait
  echo "Sending save file to other servers, please wait..."
  rm $FILE
  sudo -u streamer scp $SAVE streamer@uk.nethackathon.org:$SAVE
  sudo -u streamer scp $SAVE streamer@nethackathon.org:$SAVE
  sudo -u streamer ssh streamer@uk.nethackathon.org rm $FILE
  sudo -u streamer ssh streamer@nethackathon.org rm $FILE
  echo "Done! The next streamer can run nethackathon now."
fi
