import dbus
try:
    session_bus = dbus.SessionBus()
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
    print("%{T4}Now playing:%{T-} "+title + " - " + artist + " %{A:playerctl play:}  %{A}")
except dbus.exceptions.DBusException:
    print()
