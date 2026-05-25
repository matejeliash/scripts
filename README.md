# Scripts

Collection of various scripts, mainly written in POSIX shell and intended for Linux.

## Scripts Explained

### convert*.sh

Scripts with this prefix convert videos to the format specified in the script name.

### ytmd.sh

Downloads music from YouTube Music using a provided YouTube URL, where the best `.opus` or `.aac` stream is selected. Audio files contain song metadata and cover art. If the provided link corresponds to a playlist, an `.m3u` file is created.

### TV-convert.sh

This script converts videos so they can be played on older TVs. Supported video codec is H.264, and supported audio codecs are AAC, AC-3, and MP3.

### gnome_setup.sh

Configures GNOME to use static workspaces. `Win + number` switches focus to a workspace, `Win + Shift + number` moves the focused window to a workspace, and `Alt + Tab` switches between individual windows.
