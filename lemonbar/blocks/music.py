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
        out="%{A:/home/patrik/.config/lemonbar/previous.sh:}%{A}%{A:/home/patrik/.config/lemonbar/playpause.sh:}%{T5}"+musicon+"%{T-}%{A}%{A:/home/patrik/.config/lemonbar/next.sh:}%{}%{A} "
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
        print(out+"%{T1}"+mustext+"%{T-} "+title + " - " + artist )
except dbus.exceptions.DBusException:
    print()