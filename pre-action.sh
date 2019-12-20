#!/bin/sh

#  pre-action.sh
#  siteify
#
#  Created by John Holdsworth on 20/12/2019.
#  Copyright © 2019 John Holdsworth. All rights reserved.

if [ ! -d .build ]; then
    swift package resolve
    cd .build/checkouts/GitInfo
    ln -s ../../../.build
fi
