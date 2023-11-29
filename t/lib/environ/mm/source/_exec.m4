__workdir/gen_env
set -a
source __workdir/conf.env
set +a

__workdir/db/status >& /dev/null || __workdir/db/start "--transaction-isolation=read-committed"
[ -e __workdir/db/sql_mm_test ] || __workdir/db/create_db mm_test

(
cd __workdir/

perl minion.pl start >> __workdir/.cout 2>> __workdir/.cerr &
pid=$!
echo $pid > __workdir/.pid
)
sleep 0.1
__workdir/status || sleep 0.1
__workdir/status || sleep 0.2
__workdir/status || sleep 0.5
# __workdir/status || sleep 0.7
# __workdir/status || sleep 1
# __workdir/status || sleep 2
