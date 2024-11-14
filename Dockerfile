FROM ubuntu:noble@sha256:99c35190e22d294cdace2783ac55effc69d32896daaa265f0bbedbcde4fbe3e5

ENV PATH "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

COPY kube-sync /usr/local/bin/kube-sync

USER nobody
CMD /usr/local/bin/kube-sync
