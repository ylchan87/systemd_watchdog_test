#!/bin/bash

watchdog() {

    FIRST_SUCCESS=0

    while(true); do
        FAIL=0

        curl http://localhost:8080 --max-time 1 > /dev/null 2>&1 || FAIL=1

        if [[ $FAIL -eq 0 ]]; then
            if [[ $FIRST_SUCCESS -eq 0 ]]; then
                echo "Watchdog probed server is up for first time"
                FIRST_SUCCESS=1;
                /bin/systemd-notify --ready;
            else
                echo "Watchdog probed server is up"
                /bin/systemd-notify WATCHDOG=1;
            fi
            sleep $(($WATCHDOG_USEC / 2000000))
        else
            echo "Watchdog probed server is not responding"
            sleep 1
        fi
    done
}

watchdog &

PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
python3 ${PROJECT_ROOT}/buggy_server.py