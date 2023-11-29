#!../lib/test-in-container-environ.sh
set -ex

mm=$(environ mm $(pwd))

# process 5 jobs at a time and check any messages
for i in {1..10}; do
    $mm/enqueue test
    $mm/enqueue test
    $mm/enqueue test
    $mm/enqueue test
    $mm/enqueue test
    $mm/enqueue test
    $mm/enqueue test
    $mm/enqueue test
    $mm/enqueue test

    out=$($mm/shoot 2>&1)

    test -z "$out" || (
        2>&1 echo fail: found unespected message: $out
        exit 1
    )
done

echo success
