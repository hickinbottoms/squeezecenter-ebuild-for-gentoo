# /etc/conf.d/squeezeboxserver

# Niceness level for the Squeezebox Server process.  If not specified then the
# default is to run at standard priority.  Uncomment the following to run at a
# high priority (in order to try to minimise drop-outs due to audio starvation
# of the players).  Note that this requires "OpenRC", which will become the
# standard init system for Gentoo at some point.  If you are not using OpenRC
# yet, this setting will have no effect:
#SBS_NICENESS=-10

# Default path of your music library and playlists.  You can leave these
# undefined and configure them through the web interface instead.
#SBS_DIR=/mnt/media/Music
#SBS_PLAYLISTS_DIR=/mnt/media/Playlists

# The following contains any other options you want to specify, such as default
# logging options.  The example below will prevent the discovery and display of
# UPnP devices within your players.
#
# See "squeezeboxserver --help" for a full list of possible options,
# but note that many of them are supplied by /etc/init.d/squeezeboxserver
# and so don't need to be present here.
#SBS_OPTS="--d_startup"
SBS_OPTS=""
