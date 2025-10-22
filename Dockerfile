FROM docker.io/ubuntu:latest

# Install essential packages
RUN apt-get -y update && apt-get -y --no-install-recommends --no-install-suggests install \
    wget tini xdotool gpg openbox ca-certificates \
    python3-pip python3-venv git \
    dbus dbus-x11 gnome-keyring libsecret-1-0 libsecret-1-dev \
    nodejs npm build-essential \
    dos2unix binutils && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /tmp/.X11-unix /run/dbus && \
    chmod 1777 /tmp/.X11-unix && \
    chmod 755 /run/dbus

RUN mkdir -p /root/.local/share/keyrings /root/.cache

# Install Python dependencies
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir keyring

# Update CA certificates
RUN update-ca-certificates

# Copy noVNC files
RUN git clone https://github.com/novnc/noVNC.git /noVNC

# Install TurboVNC
RUN wget -q -O- https://packagecloud.io/dcommander/turbovnc/gpgkey | gpg --dearmor > /etc/apt/trusted.gpg.d/TurboVNC.gpg && \
    wget -q -O /etc/apt/sources.list.d/turbovnc.list https://raw.githubusercontent.com/TurboVNC/repo/main/TurboVNC.list && \
    apt-get -y update && apt-get -y install turbovnc libwebkit2gtk-4.1-0 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Download wipter package based on architecture
ARG TARGETARCH
RUN case "${TARGETARCH}" in \
      amd64) wget -q -O /tmp/wipter-app.tar.gz https://provider-assets.wipter.com/latest/linux/x64/wipter-app-x64.tar.gz ;; \
      arm64) wget -q -O /tmp/wipter-app.tar.gz https://provider-assets.wipter.com/latest/linux/arm64/wipter-app-arm64.tar.gz ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    mkdir -p /root/wipter && \
    tar -xzf /tmp/wipter-app.tar.gz -C /root/wipter --strip-components=1 && \
    rm /tmp/wipter-app.tar.gz

# Install system dependencies
RUN apt-get -y update && \
    apt-get -y install curl iputils-ping net-tools apt-transport-https libnspr4 libnss3 libxss1 libssl-dev && \
    apt-get -y --fix-broken --no-install-recommends --no-install-suggests install && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy start script
COPY start.sh /root/

# Convert to Unix line endings and make executable
RUN dos2unix /root/start.sh && \
    chmod +x /root/start.sh

# Expose ports
EXPOSE 5900 6080

# Use tini as entrypoint
ENTRYPOINT ["tini", "-s", "/root/start.sh"]
