set -e
[ -e __workdir/conf.env ] || (

echo __dbi='$(__workdir/db/print_dbi mm_test)'

echo export TEST_MYSQL='${__dbi//\/ma\//\/db\//}'

echo "
export MOJO_LISTEN=http://*:__port
export MOJO_PUBSUB_EXPERIMENTAL=1
"

    for i in "$@"; do
        [ -z "$i" ] || echo "export $i" >> __workdir/conf.env
    done
) > __workdir/conf.env
