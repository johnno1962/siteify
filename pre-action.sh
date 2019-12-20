#!/bin/sh

#  pre-action.sh
#  siteify
#
#  Created by John Holdsworth on 20/12/2019.
#  Copyright © 2019 John Holdsworth. All rights reserved.

swift package resolve

# GitInfo xcodeproj creates this link due
# to packages referenced inside the package.
 ln -s ../../../.build .build/checkouts/GitInfo
