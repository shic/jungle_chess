#!/bin/sh
set -eu

# Flutter native assets and generated plugin packages can embed frameworks
# without copying matching dSYMs into the .xcarchive.
if [ "${ACTION:-}" != "install" ]; then
  exit 0
fi

if [ "${PLATFORM_NAME:-}" != "iphoneos" ]; then
  exit 0
fi

dsym_folder="${DWARF_DSYM_FOLDER_PATH:-}"

if [ -z "$dsym_folder" ]; then
  echo "warning: DWARF_DSYM_FOLDER_PATH is empty; cannot archive framework dSYMs."
  exit 0
fi

mkdir -p "$dsym_folder"

copy_framework_dsym() {
  framework_name="$1"
  binary_name="$2"
  framework_binary="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}/${framework_name}.framework/${binary_name}"
  dsym_path="${dsym_folder}/${framework_name}.framework.dSYM"

  if [ ! -f "$framework_binary" ]; then
    echo "${framework_name}.framework was not embedded; skipping dSYM copy."
    return 0
  fi

  rm -rf "$dsym_path"
  xcrun dsymutil "$framework_binary" -o "$dsym_path"

  binary_uuids="$(xcrun dwarfdump --uuid "$framework_binary" | awk '{print $2}' | sort)"
  dsym_uuids="$(xcrun dwarfdump --uuid "$dsym_path" | awk '{print $2}' | sort)"

  for uuid in $binary_uuids; do
    if ! printf '%s\n' "$dsym_uuids" | grep -qx "$uuid"; then
      echo "error: ${framework_name}.framework.dSYM is missing UUID $uuid" >&2
      exit 1
    fi
  done

  echo "Archived ${framework_name}.framework.dSYM:"
  xcrun dwarfdump --uuid "$dsym_path"
}

copy_framework_dsym "objective_c" "objective_c"
copy_framework_dsym "GoogleMobileAds" "GoogleMobileAds"
copy_framework_dsym "UserMessagingPlatform" "UserMessagingPlatform"
