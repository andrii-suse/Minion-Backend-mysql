#!../lib/test-in-container-environ.sh
set -ex

mm=$(environ mm $(pwd))

$mm/start
$mm/status
$mm/enqueue test
$mm/shoot

$mm/sql_test 1 == "select count(*) from minion_jobs where state = 'finished'"

echo success
