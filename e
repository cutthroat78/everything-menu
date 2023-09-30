#!/bin/sh

PATH=$PATH:~/.local/bin

browsers_csv='Brave,brave --new-tab
PW,brave --incognito
Tor,brave --incognito --tor
Guest,brave --guest
TG,brave --incognito --tor --guest
surf,surf'

browser_names=$(echo "$browsers_csv" | cut -d ',' -f 1)

bookmarks_csv="Google,google.com
Random Wikipedia Article,https://wikipedia.org/wiki/Special:Random"

bookmark_names=$(echo "$bookmarks_csv" | cut -d ',' -f 1)

SAVEIFS=$IFS

IFS='
'

bookmarks=$(for s in $bookmark_names
do
for b in $browser_names
    do
      echo "$b $s"
    done
done)

searchs_csv="Anki Decks,ankiweb.net/shared/decks/,ankiweb.net/shared/decks/
Arch Packages,archlinux.org,archlinux.org/packages/?q=
AUR,aur.archlinux.org,aur.archlinux.org/packages?K=
DDG,duckduckgo.com,duckduckgo.com/
GitHub,github.com,github.com/search?q=
Google,google.com,google.com/search?q=
Scholar,https://scholar.google.com,https://scholar.google.com/scholar?hl=en&as_sdt=0%252C5&q=
Invidious,yewtu.be,yewtu.be/search?q=
YouTube,youtube.com,youtube.com/results?search_query=
Foclóir,https://www.focloir.ie/en/,https://www.focloir.ie/en/dictionary/ei/
Teanglann (English-Irish),https://www.teanglann.ie/en/eid/,https://www.teanglann.ie/en/eid/
Teanglann (Irish-English),https://www.teanglann.ie/en/fgb/,https://www.teanglann.ie/en/fgb/
Amazon (UK),https://www.amazon.co.uk,https://www.amazon.co.uk/s?k=
Etsy,https://www.etsy.com,https://www.etsy.com/ie/search?q=
Quizlet,https://quizlet.com/,https://quizlet.com/search?query=
WikiHow,https://www.wikihow.com,https://www.wikihow.com/wikiHowTo?search="

search_names=$(echo "$searchs_csv" | cut -d ',' -f 1)

searchs=$(for s in $search_names
do
for b in $browser_names
    do
      echo "$b $s"
    done
done)

IFS=$SAVEIFS

date_and_time() {
  if [[ "$2" == "time" ]]; then
    date --date=$1 +"%F %H-%M-%S"
  else
    date --date=$1 +"%F"
  fi
}

commands_csv='Desktop Audio Record,$TERM_RUN ffmpeg -f pulse -i default -acodec libmp3lame -ab 320k ~/$(date +"%F-%H-%M-%S").mp3
Computer Room Light On,hass-cli state turn_on light.0x94103ea2b278513d
Computer Room Light Off,hass-cli state turn_off light.0x94103ea2b278513d
Computer Room Light Toggle,hass-cli state toggle light.0x94103ea2b278513d
Check Internet,ping 1.1.1.1
External IP,curl ifconfig.me
shutdown,shutdown -h now
TS Up,sudo tailscale up
TS Down,sudo tailscale down
TS Status,tailscale status
TS Disable Exit Node,sudo tailscale up --exit-node=
Hblock Enable,hblock
Hblock Disable,hblock -S none -D none
To Dos,alacritty -e zsh -i -c "ranger ~/sync/to-dos/"
Media,alacritty -e zsh -i -c "nvim ~/sync/media.md"
Dailies,alacritty -e zsh -i -c "nvim ~/sync/dailies/$(date +"%F").md"
Dailies Yesterday,alacritty -e zsh -i -c "nvim ~/sync/dailies/$(date --date=yesterday +"%F").md"
Dailies Tomorrow,alacritty -e zsh -i -c "nvim ~/sync/dailies/$(date --date=tomorrow +"%F").md"
Quick Note,alacritty -e zsh -i -c "nvim ~/sync/quick-note.md"
Type F1,xdotool key F1
Type F2,xdotool key F2
Type F3,xdotool key F3
Type F4,xdotool key F4
Type F5,xdotool key F5
Type F6,xdotool key F6
Type F7,xdotool key F7
Type F8,xdotool key F8
Type F9,xdotool key F9
Type F10,xdotool key F10
Type F11,xdotool key F11
Type F12,xdotool key F12
Type + (Plus),xdotool type +
Type - (Minus),xdotool type -
Type / (Forward Slash),xdotool type /
Type \ (Backslash),xdotool type \'

commands=$(echo "$commands_csv" | cut -d ',' -f 1)

custom_entries="Scratchpad
Spotify Loop Menu
Volume
Brightness
Greyscale
Layout
Type
Type-E-Menu
Z
Z-R
Clear History
Tag
Tag Make
Tag Delete
@clip
mpv @clip
Brave @clip
Brave Google @clip
Brave DDG @clip
PW @clip
PW Google @clip
PW DDG @clip
surf @clip
surf Google @clip
surf DDG @clip
Type Glass of Sparkling Water
YT
YT @clip
YT Audio
YT Audio @clip
YT Playlist
YT Playlist @clip
YT Link
YT Link @clip"

cli="ttyper nmtui newsboat ranger nvim vim alsamixer yay top htop glances pacman Check Internet TS Up TS Down TS Disable Exit Node Hblock Enable Hblock Disable"

cli_hold="External IP TS Status"

custom="$custom_entries
$commands
$bookmarks
$searchs
$bookmark_names
$search_names
$browser_names"

entries_without_hist=$(echo -e "$custom\n$(dmenu_path)" | sort -n)

hist=$(cat ~/.e-history)

entries_with_hist=$(echo -e "$hist\n$entries_without_hist")

if [[ -z "$1" ]]; then
  isxclient=$( readlink /dev/fd/2 | grep -q 'tty' && [[ -n $DISPLAY ]] ; echo $? )
  if [[ ! -t 2  || $isxclient == "0" ]]; then
    cmd=$(echo "$entries_with_hist" | rofi -dmenu -i)
    menu_used="ext"
  else
    cmd=$(echo "$entries_with_hist" | pmenu)
    menu_used="term"
  fi
else
  cmd="$@"
fi

if [[ -z "$cmd" ]]; then # This is to stop a terminal from popping up if I exit dmenu (by using escape or otherwise)
  exit
fi

if [[ ! "$cmd" == "Type-E-Menu"* ]]; then
  if [[ $(wc -l ~/.e-history) > 9 ]]; then
    sed -i '$ d' ./.e-history
  fi

  new_hist=$(echo -e "$cmd\n$(cat ~/.e-history)")
  echo "$new_hist" > ~/.e-history
fi

if [[ "$cli" == *"$cmd"* ]]; then
  cmd+="!"
fi

if [[ "$cli_hold" == *"$cmd"* ]]; then
  cmd+="$"
fi

if [[ "$cmd" == *! ]] || [[ "$cmd" == *$ ]]; then
  if [[ "$menu_used" == "term" ]]; then
    cmd="${cmd::-1}"
    search="$cmd"
  else
    search="${cmd::-1}"
  fi
else
  search="$cmd"
fi

SAVEIFS=$IFS

IFS='
'

for b in $browser_names
do
  if [[ "${search,,}" == "${b,,}"* ]]; then
    grabbed_browser=$b
    break
  else
    continue
  fi
done

for b in $bookmark_names
do
  if [[ "${search,,}" == *"${b,,}" ]]; then
    grabbed_bookmark=$b
    break
  else
    continue
  fi
done

for s in $search_names
do
  if [[ "${search,,}" == *"${s,,}"* ]]; then
    grabbed_search=$s
    break
  else
    continue
  fi
done

IFS=$SAVEIFS

if [[ "${search,,}" == "${grabbed_bookmark,,}" ]]; then
  search="$(echo "xdotool type " $(echo "$bookmarks_csv" | grep -m 1 -iF "${search,,}" | cut -d ',' -f 2))"
fi

if [[ "${search,,}" == "${grabbed_search,,}" ]]; then
  search="$(echo "xdotool type " $(echo "$searchs_csv" | grep -m 1 -iF "${search,,}" | cut -d ',' -f 2))"
fi

if [[ "${search,,}" == "${grabbed_browser,,}" ]]; then
  search=$(echo "$browsers_csv" | grep -m 1 -iF "${search,,}" | cut -d ',' -f 2)
fi

if [[ "${search,,}" == "${grabbed_browser,,} "* ]]; then
  if [[ "${search,,}" == *" ${grabbed_bookmark,,}" ]]; then
    search="$(echo $(echo "$browsers_csv" | grep -m 1 -iF "${grabbed_browser,,}" | cut -d ',' -f 2) $(echo " ") $(echo "$bookmarks_csv" | grep -m 1 -iF "$grabbed_bookmark" | cut -d ',' -f 2))"
  else
    if [[ "${search,,}" == *" ${grabbed_search,,} "* ]]; then
      non_sterm=$(echo $(echo "$grabbed_browser") $(echo " ") $(echo "$grabbed_search"))
      sterm=$(echo "$search" | sed "s,${non_sterm,,} ,,i")
      search="$(echo $(echo "$browsers_csv" | grep -m 1 -iF "${grabbed_browser,,}" | cut -d ',' -f 2) $(echo '"')$(echo "$searchs_csv" | grep -m 1 -iF "$grabbed_search" | cut -d ',' -f 3)$(echo "$sterm\""))"
    else
      if [[ "${search,,}" == *" ${grabbed_search,,}" ]]; then
        search="$(echo $(echo "$browsers_csv" | grep -m 1 -iF "${grabbed_browser,,}" | cut -d ',' -f 2) $(echo " ") $(echo "$searchs_csv" | grep -m 1 -iF "$grabbed_search" | cut -d ',' -f 2))"
      else
        search=$(echo $search | sed "s,${grabbed_browser,,},$(echo "${browsers_csv,,}" | grep -m 1 -iF "${grabbed_browser,,}" | cut -d ',' -f 2),i" )
      fi
    fi
  fi
fi

if [[ "$search" == *"@clip"* ]]; then
  search=$(echo "$search" | sed "s,@clip,$(xclip -o -sel clip),")
fi

case ${search,,} in # Make sure to make all options in lower case even if entry in the list above it is in all uppercase or a mixture of lower and uppercase
   "tag make"*)
     tag_name="$(echo $search | cut -c10-)"
     cmd2="herbstclient add \"$tag_name\""
     ;;

   "tag delete"*)
     tag_name="$(echo $search | cut -c12-)"
     cmd2="herbstclient merge_tag \"$tag_name\""
     ;;

   "tag"*)
     tag_name="$(echo $search | cut -c5-)"
     cmd2="herbstclient use \"$tag_name\""
     ;;

  "spotify loop menu")
    option=$(echo -e "none\ntrack\nplaylist" | $EXT_MENU)

    playerctl -p spotify loop "$option"
    ;;
  "clear history")
    rm ~/.e-history
    touch ~/.e-history
    ;;

  "z-r"*)
    cmd_dir="$(echo $search | cut -c5-)"
    cmd2="alacritty -e zsh -i -c \"z "$cmd_dir" && ranger\""
    ;;

  "z"*)
    cmd_dir="$(echo $search | cut -c3-)"
    cmd2="alacritty -e zsh -i -c \"z "$cmd_dir" && zsh\""
    ;;

  "type-e-menu"*)
    sterm="$(echo $search | cut -c13-)"
    cmd2="sh \"/home/cutthroat/work/unraid/dotfiles/e\" & sleep 0.2; xdotool type \"$sterm\""
    ;;
 
  "type"*)
    if [[ "${commands,,}" == *"${search,,}"* ]]; then
      cmd2=$(echo "$commands_csv" | grep -m 1 -iF "${search,,}" | cut -d ',' -f 2)
    else
      sterm="$(echo $search | cut -c6-)"
      cmd2="xdotool type \"$sterm\""
    fi
    ;;

  "scratchpad"*)
    sterm="$(echo $search | cut -c12-)"
    cmd2="~/.config/herbstluftwm/scratchpad \"$sterm\""
    ;;

  "yt playlist"*)
    sterm="$(echo $search | cut -c13-)"
    if [[ -z "$sterm" ]]; then
      cmd2="ytfzf -D --type=playlist"
    else
      cmd2="ytfzf -D --type=playlist $sterm"
    fi
    ;;

  "yt audio"*)
    sterm="$(echo $search | cut -c10-)"
    if [[ -z "$sterm" ]]; then
      cmd2="alacritty -e ytfzf -D -m"
    else
      cmd2="alacritty -e ytfzf -D -m $sterm"
    fi
    ;;

  "yt link"*)
    sterm="$(echo $search | cut -c9-)"
    if [[ -z "$sterm" ]]; then
      cmd2="ytfzf -D -L | xclip -selection clipboard"
    else
      cmd2="ytfzf -D -L \"$sterm\" | xclip -selection clipboard"
    fi
    ;;

  "yt"*)
    sterm="$(echo $search | cut -c4-)"
    if [[ -z "$sterm" ]]; then
      cmd2="ytfzf -D"
    else
      cmd2="ytfzf -D \"$sterm\""
    fi
    ;;

  "layout"*)
    layout="$(echo $search | cut -c7-)"
    if [[ -z "$layout" ]]; then
      layout=$(ibus list-engine --name-only | $EXT_MENU -p "Layout")
    fi
    cmd2="ibus engine $layout"
    ;;

  "greyscale")
    killall picom

    TOGGLE=$HOME/.greyscale-toggle

    if [ ! -e $TOGGLE ]; then
      touch $TOGGLE
      cmd2="picom &"
    else
      rm $TOGGLE
      cmd2="picom --backend glx --glx-fshader-win \"$(cat ~/.config/picom/greyscale.glsl)\" --legacy-backends &"
    fi
    ;;

  "brightness"*) 
    brightness="$(echo $search | cut -c11-)"
    if [[ -z "$brightness" ]]; then
      brightness=$(echo -e "5\n10\n15\n20\n25\n30\n35\n40\n45\n50\n55\n60\n65\n70\n75\n80\n85\n90\n95\n100\n110\n120\n130\n140\n150\n160\n170\n180\n190\n200\n210\n220\n230\n240\n250\n255" | $ext_menu -p "Brightness")
    fi
    cmd2="brightnessctl s $brightness"
    ;;

  "volume"*)
     volume="$(echo $search | cut -c7-)"
    if [[ -z "$volume" ]]; then
      volume=$(echo -e "5\n10\n15\n20\n25\n30\n35\n40\n45\n50\n55\n60\n65\n70\n75\n80\n85\n90\n95\n100" | $ext_menu -p "Volume")
    fi
    cmd2="pactl set-sink-volume 0 $volume%"
    ;;

  *)
    cmd2=$search
    if [[ "${commands,,}" == *"${search,,}"* ]]; then
      cmd2=$(echo "$commands_csv" | grep -m 1 -iF "${search,,}" | cut -d ',' -f 2)
    fi
    ;;
esac

if [[ "$cmd" == *! ]]; then
  $TERM_RUN $cmd2
else
  if [[ "$cmd" == *$ ]]; then
    $TERM_HOLD $cmd2
  else
    sh -c "$cmd2"
  fi
fi
