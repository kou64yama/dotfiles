#!/usr/bin/env bash

set -eo pipefail

/usr/bin/env bash stage1/install.sh
/usr/bin/env bash stage2/install.sh
/usr/bin/env bash stage3/install.sh
