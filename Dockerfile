FROM ubuntu:24.04

RUN apt update && apt install openconnect -y

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
