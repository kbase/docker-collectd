# docker-collectd
A KBase specific version of CollectD that runs within a container.

This image expects that /proc and /sys from the host environment be mounted (read-only) into the running container at
/rootfs/proc and /rootfs/sys. Then when collectd is run, any attempts to open /proc or /sys will have
/rootfs/proc and /rootfs/sys substituted by a preloaded library module, allowing collected to read stats from the
parent environment.

In addition, this repo contains the docker_stats collectd python plugin from https://github.com/ajtritt/xswap_jgi and needs access to a docker socket to poll statistics.

Run with:
~~~
docker run -v /proc:/rootfs/proc:ro -v /sys:/rootfs/sys:ro -v /var/run/docker.sock:/var/run/docker.sock  kbase/docker-collectd:latest 
~~~
Original configuration from https://github.com/collectd/collectd/tree/master/contrib/docker

