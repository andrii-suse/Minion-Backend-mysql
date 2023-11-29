__workdir/gen_env
set -a
source __workdir/conf.env
set +a

__workdir/db/status >& /dev/null || __workdir/db/start "--transaction-isolation=read-committed"
[ -e __workdir/db/sql_mm_test ] || __workdir/db/create_db mm_test

(
cd __workdir/

perl minion.pl "$@"
)
