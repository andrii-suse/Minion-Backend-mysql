set -e
curl -sI http://127.0.0.1:__port/ | grep '200' || ( >&2 echo "MINION (__port) is not reachable"; exit 1 )
