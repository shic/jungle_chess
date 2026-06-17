#!/bin/sh
set -eu

# Flutter native assets can embed package:objective_c without copying its dSYM
# into the .xcarchive. App Store Connect expects a matching dSYM for every
# embedded framework UUID.
if [ "${ACTION:-}" != "install" ]; then
  exit 0
fi

if [ "${PLATFORM_NAME:-}" != "iphoneos" ]; then
  exit 0
fi

framework_binary="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}/objective_c.framework/objective_c"
dsym_folder="${DWARF_DSYM_FOLDER_PATH:-}"
dsym_path="${dsym_folder}/objective_c.framework.dSYM"

if [ ! -f "$framework_binary" ]; then
  echo "objective_c.framework was not embedded; skipping dSYM copy."
  exit 0
fi

if [ -z "$dsym_folder" ]; then
  echo "warning: DWARF_DSYM_FOLDER_PATH is empty; cannot archive objective_c.framework.dSYM."
  exit 0
fi

mkdir -p "$dsym_folder"
rm -rf "$dsym_path"
xcrun dsymutil "$framework_binary" -o "$dsym_path"

binary_uuids="$(xcrun dwarfdump --uuid "$framework_binary" | awk '{print $2}' | sort)"
dsym_uuids="$(xcrun dwarfdump --uuid "$dsym_path" | awk '{print $2}' | sort)"

for uuid in $binary_uuids; do
  if ! printf '%s\n' "$dsym_uuids" | grep -qx "$uuid"; then
    echo "error: objective_c.framework.dSYM is missing UUID $uuid" >&2
    exit 1
  fi
done

echo "Archived objective_c.framework.dSYM:"
xcrun dwarfdump --uuid "$dsym_path"
