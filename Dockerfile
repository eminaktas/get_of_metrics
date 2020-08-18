FROM debian:bullseye

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

LABEL mainainer="Emin Aktas<eminaktas34@gmail.com>"
LABEL version="3.0.0"
LABEL description="Get of Metrics Docker Image for get-of-metrics Exporter"

COPY ./get-of-metrics.deb ./

RUN `# Updating Package List`                                                  && \
     apt-get update                                                            && \
                                                                               \
    `# Installing packages`                                                    && \
     apt-get install -y ./get-of-metrics.deb                                   && \
                                                                                \
     apt-get install -y systemd systemd-sysv                                   && \
                                                                               \
     apt-get install -y python3-prometheus-client                              && \
                                                                               \
     `# Cleaning up after installation`                                        && \
     apt-get clean                                                             && \
                                                                               \
     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /get-of-metrics.deb

COPY ./connection-parameters.json ./home/get-of-metrics/

RUN `#Fixing permission error for volume`                                                      && \
     chown -R 1000:1000 /home/get-of-metrics/connection-parameters.json                        && \
                                                                                               \
     chown -R 1000:1000 /var/log/get-of-metrics                                                && \
                                                                                               \
     chown -R 1000:1000 /etc/systemd/system/get-of-metrics.service

VOLUME [ "/sys/fs/cgroup" ]
VOLUME [ "/home/get-of-metrics" ]
VOLUME [ "/var/log/get-of-metrics" ]

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
    /lib/systemd/system/systemd-update-utmp*

ENTRYPOINT ["/lib/systemd/systemd"]


CMD  `#Enabling the systemd`                                                    && \
     /lib/systemd/systemd                                                       && \
                                                                                \
     `#Enabling the service`                                                    && \
     systemctl enable get-of-metrics                                            && \
                                                                                \
     `#Starting the service`                                                    && \
     systemctl start get-of-Metrics
     
EXPOSE 8000