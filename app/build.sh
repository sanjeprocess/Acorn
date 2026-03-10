#!/bin/bash

# Exit immediately if any command fails
set -e

# Get the current version line from pubspec.yaml
version_line=$(grep '^version:' pubspec.yaml)

# Extract version name and build number
version_name=$(echo $version_line | cut -d+ -f1 | awk '{print $2}')
build_number=$(echo $version_line | cut -d+ -f2)

# Increment build number
new_build_number=$((build_number + 1))

# Update pubspec.yaml with new version
sed -i.bak "s/version: $version_name+$build_number/version: $version_name+$new_build_number/" pubspec.yaml

echo "✅ Updated version to $version_name+$new_build_number"

# Run flutter build (apk in this example)
flutter build apk --no-tree-shake-icons 
flutter build appbundle --no-tree-shake-icons 


# How to run 
# chmod +x build.sh
# ./build.sh