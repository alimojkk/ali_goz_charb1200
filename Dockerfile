FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tehran
ENV LANG=C.UTF-8
ENV TERM=xterm-256color
ENV SERVER_NAME=manixshop
ENV PORT=7681

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server sudo curl wget git nano vim htop \
    ca-certificates tzdata unzip zip tmux screen \
    python3 python3-pip build-essential net-tools iproute2 \
    dnsutils iputils-ping locales \
    && rm -rf /var/lib/apt/lists/*

# ---- وب ترمینال (ttyd) ----
ARG TTYD_VERSION=1.7.7
RUN ARCH="$(dpkg --print-architecture)" && \
    case "$ARCH" in \
      amd64) TTYD_ARCH=x86_64 ;; \
      arm64) TTYD_ARCH=aarch64 ;; \
      *) TTYD_ARCH=x86_64 ;; \
    esac && \
    curl -fsSL -o /usr/local/bin/ttyd \
      "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.${TTYD_ARCH}" && \
    chmod +x /usr/local/bin/ttyd

RUN mkdir -p /var/run/sshd /root/.ssh /data && chmod 700 /root/.ssh

RUN sed -i 's/#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#\?ClientAliveInterval.*/ClientAliveInterval 30/' /etc/ssh/sshd_config && \
    echo "ClientAliveCountMax 10" >> /etc/ssh/sshd_config && \
    echo "UseDNS no" >> /etc/ssh/sshd_config

COPY start.sh /start.sh
RUN chmod +x /start.sh

# Railway auto-detects this single port for the public domain
EXPOSE 7681
CMD ["/start.sh"]
