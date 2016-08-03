#!/usr/bin/env python3

from subprocess import check_output

# Appearance
geometry = "x15"
width    = int(check_output("xrandr | grep current | awk '{print $8a}'", shell=True))
font     = "-xos4-terminesspowerline-medium-r-normal--12-120-72-72-c-60-iso10646-1"
iconfont = "-xos4-terminusicons2mono-medium-r-normal--12-120-72-72-m-60-iso8859-1"

color_back    = "#FF1D1F21"      # Default background
color_fore    = "#FFC5C8C6"      # Default foreground
color_head    = "#FFB5BD68"      # Background for first element
color_sec_b1  = "#FF282A2E"      # Background for section 1
color_sec_b2  = "#FF454A4F"      # Background for section 2
color_sec_b3  = "#FF60676E"      # Background for section 3
color_icon    = "#FF979997"      # For icons
color_mail    = "#FFCE935F"      # Background color for mail alert
color_chat    = "#FFCC6666"      # Background color for chat alert
color_cpu     = "#FF5F819D"      # Background color for cpu alert
color_net     = "#FF5E8D87"      # Background color for net alert
color_disable = "#FF1D1F21"      # Foreground for disable elements
color_wsp     = "#FF8C9440"      # Background for selected workspace

# Device monitoring configuration
#snd_cha=check_output('amixer get Master | grep "Playback channels:" | awk "{if ($4 == '') {printf '%s: Playback', $3} else {printf "%s %s: Playback", $3, $4}}'')

# Monitoring intervals / alerts
alert_cpu = 75                      # % cpu use
alert_net = 5                       # K net use

timer_default = 1
timer_vol     = 3                        # Volume update
timer_mail    = 300                      # Mail check update

#default space between sections
if width > 1024:
	stab = '  '
else:
	stab = ' '

# Char glyps for powerline fonts
sep_left=""                     # Powerline separator left
sep_right=""                    # Powerline separator right
sep_l_left=""                   # Powerline light separator left
sep_l_right=""                  # Powerline light sepatator right

# Icon glyphs from Terminusicons2
icon_clock="Õ"                   # Clock icon
icon_cpu="Ï"                     # CPU icon
icon_mem="Þ"                     # MEM icon
icon_dl="Ð"                      # Download icon
icon_ul="Ñ"                      # Upload icon
icon_vol="Ô"                     # Volume icon
icon_hd="À"                      # HD / icon
icon_home="Æ"                    # HD /home icon
icon_mail="Ó"                    # Mail icon
icon_chat="Ò"                    # IRC/Chat icon
icon_music="Î"                   # Music icon
icon_prog="Â"                    # Window icon
icon_contact="Á"                 # Contact icon
icon_wsp="É"                     # Workspace icon

