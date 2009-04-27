#!/bin/bash
. ../utilities/include-for-start-up.sh
# Before apt-get is useful you need to do an apt-get update.
# Because that is slow we'd rather do it only once.
begin_start_up bootstrap-apt
apt-get update
end_start_up bootstrap-apt

