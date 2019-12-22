#!/bin/sh -x

#  pre-action.sh
#  siteify
#
#  Created by John Holdsworth on 20/12/2019.
#  $Id: //depot/siteify/pre-action.sh#17 $
#
#  This script should be called from a "Pre-action" for the
#  build phase of a Xcode project scheme.
#
#  "${PROJECT_DIR}/pre-action.sh" >>/tmp/resolve.log 2>&1
#
#  It allows you to start bringing in code dependencies using
#  a Swift Package Manager Package.swift manifest file while
#  continuing to use using Xcode native format projects.
#
#  After resolution, drag the .build/checkouts/*/*.xcodeproj files
#  for each package into your project so they build as frameworks.
#

cd "$(dirname "$0")"

# Almost useful to avoid resolve on build "clean"
#if [ "$RUN_CLANG_STATIC_ANALYZER" == "YES" ]; then
#    exit
#fi

# Pre-action when packages have not been resolved
if [ "$TERM_PROGRAM" = "" ]; then
    if [ ! -d .build ]; then
        # re-run this script in terminal so it doesn't
        # get killed off when the build gets cancelled
        open -b com.apple.terminal "$0"

        # Cancel current build (restarted later)
        osascript -e 'tell application "Xcode"
            stop active workspace document
        end tell'
        sleep 5 # linger to make sure build cancels
    fi
else
    echo "\n🥁 Fetching dependencies in Package.swift..."
    swift package resolve

    echo "\n🥁 Converting SPM packages into .xcodeproj files..."
    cd .build/checkouts
    for pkg in *; do
        cd $pkg
        echo "\n🥁 Generating .build/checkouts/$pkg/$pkg.xcodeproj..."
        rm -rf $pkg.xcodeproj
        swift package generate-xcodeproj --output $pkg.xcodeproj
        rm -rf .build
        # This link is used when packages depend on packages.
        ln -s ../../../.build
        cd -
    done

    echo "\n🥁 Forcing Xcode to reload main project.."
    touch ../../*.xcodeproj/project.pbxproj

    echo "\n🏆 Messaging Xcode to restart the build."
    sleep 2 # give the project time to reload
    osascript -e 'tell application "Xcode"
        activate
        clean active workspace document
        build active workspace document
    end tell'
fi
