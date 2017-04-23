import dbus
import sys
try:
    l = sys.argv
    session_bus = dbus.SessionBus()
    if len(l) > 1:
        if str(l[1]) == "Paused":
            musicon=""
            mustext="Now playing:"
        else:
            musicon=""
            mustext="Now playing:"
        out="%{A:/home/patrik/.config/lemonbar/music.sh previous:}%{A}%{A:/home/patrik/.config/lemonbar/music.sh playpause:}%{T3}"+musicon+"%{T-}%{A}%{A:/home/patrik/.config/lemonbar/music.sh next:}%{}%{A} "
        #out="%{A:/home/patrik/.config/lemonbar/music.sh previous:}%{A}%{A:/home/patrik/.config/lemonbar/music.sh playpause:}%{T5}"+musicon+"%{T-}%{A}%{A:/home/patrik/.config/lemonbar/music.sh next:}%{}%{A} "
        spotify_bus = session_bus.get_object("org.mpris.MediaPlayer2.spotify",
                                            "/org/mpris/MediaPlayer2")
        spotify_properties = dbus.Interface(spotify_bus,
                                            "org.freedesktop.DBus.Properties")
        metadata = spotify_properties.Get("org.mpris.MediaPlayer2.Player",
                                        "Metadata")

    # The property Metadata behaves like a python dict
        # for key, value in metadata.items():
        # print(str(key) + " " + str(value))

    # To just print the title
        artist = str(metadata['xesam:artist'][0])
        title = str(metadata['xesam:title'])
        length = len(artist)+len(title)
        if length > 50:
            title = title[:50-len(artist)] + "..."
        print(out+title + " - " + artist )
except dbus.exceptions.DBusException:
    print()
