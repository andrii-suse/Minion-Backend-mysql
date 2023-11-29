#!/bin/bash
#
# Copyright (C) 2023 SUSE LLC
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, see <http://www.gnu.org/licenses/>.

T_BASE_IMAGE=${T_BASE_IMAGE:-leap}

initscript=$1
testcase=$2

[ -n "$testcase" ] || {
  testcase=$initscript
  initscript=""
}

[ -n "$testcase" ] || {
  echo "No testcase provided"
  exit 1
}

set -eo pipefail

[ -f "$testcase" ] || (echo Cannot find file "$testcase"; exit 1 ) >&2
thisdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
basename=$(basename "$testcase")
basename=${basename,,}
basename=${basename//:/_}
ident=mc.minionbackendmysqltest
containername="$ident.${basename,,}"

docker_info="$(docker info >/dev/null 2>&1)" || {
    echo "Docker doesn't seem to be running"
    (exit 1)
}

dockerfile=$thisdir/Dockerfile

[ -z "${T_BASE_IMAGE}" ] || dockerfile=$thisdir/Dockerfile.${T_BASE_IMAGE}

docker build -t $ident.image -f $dockerfile $thisdir

docker rm -f "$containername" >&/dev/null || :

map_port=""
[ -z "$EXPOSE_PORT" ] || map_port="-p 80:$EXPOSE_PORT"

docker run $map_port --rm --name "$containername" -d -v"$thisdir/../..":/opt/project -- $ident.image

in_cleanup=0

function cleanup {
    [ "$in_cleanup" != 1 ] || return
    in_cleanup=1
    if [ "$ret" != 0 ] && [ -n "$T_PAUSE_ON_FAILURE" ]; then
        read -rsn1 -p"Test failed, press any key to finish";echo
    fi
    [ "$ret" == 0 ] || echo FAIL $basename
    if [ -z "$EXPOSE_PORT" ]; then
      docker stop -t 0 "$containername" >&/dev/null || :
    fi
}

trap cleanup INT TERM EXIT
counter=1

# wait container start
until [ $counter -gt 10 ]; do
  sleep 0.5
  docker exec "$containername" pwd >& /dev/null && break
  ((counter++))
done

docker exec "$containername" pwd >& /dev/null || (echo Cannot start container; exit 1 ) >&2

set +ex
docker exec -e TESTCASE="$testcase" -i "$containername" bash -c "useradd $(id -nu) -u $(id -u) || :; sudo -E -u \#$(id -u) bash" < "$testcase"
ret=$?
( exit $ret )
