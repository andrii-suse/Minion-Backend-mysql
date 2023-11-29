Scripts for integration tests containers
-------------------

The test is set of bash commands.
The script relies on shebang to prepare an image and spawn a container with the sls files.
It is also ready to test the commands locally assuming all prerequisites are instaled.

###### Example: Run smoke test in container

```bash
sudo service docker start
```

```bash
cd t
./01-smoke.sh
```

###### Example: Run the comamnds locally

It is assumed all prerequisite of Minion-Backend-mysql are installed properly.
The testing needs environ package, install it using instructions:

https://github.com/andrii-suse/environ/blob/master/INSTALL.txt


#### Challenge 1: By default, a container is destroyed when the test finishes.

This is to simplify re-run of tests and do not flood machine with leftover containers after tests.
To make sure container stays around after faiure - set environment variable *T_PAUSE_ON_FAILURE* to 1

###### Example: Connect to the container after test failure

```bash
> # terminal 1
> echo fail >> 01-smoke.sh
> T_PAUSE_ON_FAILURE=1 ./01-smoke.sh
...
bash: line 18: fail: command not found
Test failed, press any key to finish
```
The terminal will wait for any input to finish the test and clean up the container.
