#!/bin/bash
. ../utilities/include-for-start-up.sh
begin_start_up erlang
require bootstrap-apt
apt-get --yes --force-yes  install erlang
end_start_up erlang
