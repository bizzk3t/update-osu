#!/usr/bin/env bash

# a command line tool to help update osu (the most fun game ever)

# Config Options
# ----------------------------------------------------------------------------

# Directory for github release
# For example: ~/Applications
INSTALL_DIRECTORY="$HOME/Applications"

# Name of asset used to grab from github release
DOWNLOAD_FILENAME="osu.AppImage"

# Location of local data files for osu. It may not exist right now. that's okay!
OSU_DATA_DIRECTORY="$HOME/.local/share/osu"

GITHUB_RELEASE_INFO_URL="https://api.github.com/repos/ppy/osu/releases/latest"

# cli options
# ----------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      echo "osu update cli tool (unofficial)"
      echo ""
      echo "USAGE"
      echo "    usage: ./update-osu.sh"
      echo ""
      echo "OPTIONS"
      echo "    -h, --help     print help"
      echo "    -f, --force    force download"
      echo ""
      exit 0
      ;;
    -f|--force)
      FORCE=YES
      shift
      ;;
    *)
      shift
      ;;
  esac
done

download_install() {
  echo "Downloading latest version now..."

  cd "$INSTALL_DIRECTORY"
  wget -O "$DOWNLOAD_FILENAME" "$(echo "$RELEASE_INFO" | jq -r ".assets[] | select(.name == \"$DOWNLOAD_FILENAME\").browser_download_url")"
  chmod +x "$DOWNLOAD_FILENAME"

  exit 0
}

compare_versions_install() {
  echo ""
  echo "Checking version to see if update is necessary..."
  tag_name="$(echo "$RELEASE_INFO" | jq -r '.tag_name')"
  # Version has been a date which is smart. Best way to do versions imo.
  # example: 2022.405.0

  # if a local version of osu is installed, get the version number game.ini
  # also strip the spaces and -lazer at the end
  local_version="$(awk -F '=' '/Version/ {print $2}' "$OSU_DATA_DIRECTORY/game.ini" 2> /dev/null \
    | tr -d ' ' \
    | sed 's/-lazer//g' \
    || echo '')"

  echo ""
  echo "      Local Version: ${local_version:-not installed}"
  echo "Most Recent Version: $tag_name"
  echo ""

  if [[ "$local_version" == "$tag_name" ]]; then
    echo "osu is up to date!"
    echo "Done."
    exit 0
  else
    download_install
  fi
}

check_dependencies() {
  if ! command -v jq &> /dev/null; then
    echo ""
    echo "'jq' is not installed. Please install before running."
    echo ""
    echo "download from website:"
    echo "https://stedolan.github.io/jq/"
    echo ""
    echo "Ubuntu:"
    echo "sudo apt install jq"
    echo ""
    echo "Using pip:"
    echo "pip install jq"
    echo ""
    echo "source code:"
    echo "https://github.com/stedolan/jq"
    echo ""
    exit 1
  fi

}

check_dependencies

# use github api to get version of latest release.
# RELEASE_INFO="$(cat osu.json)"
RELEASE_INFO="$(curl "$GITHUB_RELEASE_INFO_URL")"


if [[ "$FORCE" == "YES" ]]; then
  echo ""
  echo "Received '--force' option. Skipping version check."
  download_install
else
  compare_versions_install
fi



# experimental
# ----------------------------------------------------------------------------
# extract_assets() {
#   cmd=("$INSTALL_DIRECTORY/$DOWNLOAD_FILENAME" --appimage-extract)
#   # squashfs-root/osu!.png
#   # squashfs-root/osu!.desktop
# }
#
# create_desktop_file() {
#   desktop_install_location="$HOME/.local/share/applications"
#   desktop_file_name="osu!.desktop"
#   desktop_full_path="/.local/share/applications/$desktop_file_name"
#
#   if [[ ! -d  "d" ]]
#   cat <<'EOF' >> $desktop_full_path
# Desktop Entry Specification: https://standards.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html
# [Desktop Entry]
# Name=osu!
# Comment=A free-to-win rhythm game. Rhythm is just a *click* away!
# Exec=$HOME/Applications/osu.AppImage
# Icon=$HOME/.local/share/icons/hicolor/1024x1024/apps/osu!.png
# Terminal=false
# Type=Application
# Categories=Game;
# EOF 
#
# }

# old download method without checking version info first:
#
# curl "https://api.github.com/repos/ppy/osu/releases/latest" \
# | grep -E "https://.*osu\.AppImage\"" \
#   | cut -d : -f 2,3 \
#   | tr -d \" \
#   | wget -qi -
#


