# About

systemd would restart service if the service crashes, but sometimes the service do not crash but hangs, and the service is not restarted.

We can setup a watchdog and call systemd's `Notify` function to notify systemd of our servives health. systemd would auto restart the service if these health notification is missing for too long.


# File descriptions
- buggy_server.py : a server that hangs randomly

- buggy_server.service : our service

- run_buggy_server.bash : script to start the server and the watchdog, we use curl to check if the server is still healthy, if healthy, send a msg to systemd

# Install and test

1. install the service\
`bash install.bash`

2. start the service\
`systemctl start buggy_server.service`

3. monitor the service\
`journalctl -fu buggy_server.service`

4. confirm the server can recover after it hangs\
visit `localhost:8080`

# Dev note 
## about buggy_server.service

Key lines to look at:

- `Type=Notify`\
This tells systemd to use the "listen for health notification" function for this service\
Note that when we set `Type=Notify` for the service, we need to notify systemd when our service is done initializing and actually up\
We do so by calling `/bin/systemd-notify --ready` in our watchdog\
If not, systemd will wait, i.e. `systemctl start xxx.service` will block, and other services that depend on xxx.service will not be started

- `NotifyAccess=all`\
By default only the process itself, i.e. the python server, can notify systemd about its alive status. So we need `NotifyAccess=all` to let our watchdog, which has a separate Process ID, to send notify messages.


- `WatchdogSec=5`\
systemd will restart the service if no new notification within 5sec

## about watchdog
watchdog is defined in `run_buggy_server.bash`

two key things to note:
- `/bin/systemd-notify --ready;` : notify systemd out server is now up and running, else systemd will think the server is still initializing
            
- `/bin/systemd-notify WATCHDOG=1;` : notify systemd out server is still healthy, don't kill it yet.

# Ref

https://www.medo64.com/2019/01/systemd-watchdog-for-any-service/

https://www.freedesktop.org/software/systemd/man/systemd.service.html