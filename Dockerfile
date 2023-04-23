FROM docker.io/library/ubuntu:jammy
ENV DEBIAN_FRONTEND noninteractive
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
