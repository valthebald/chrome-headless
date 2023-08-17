#######
# Base
#######
FROM debian:bookworm

ENV DRUPALCI TRUE
ENV DBUS_SESSION_BUS_ADDRESS="/dev/null"

# Install deps + add Chrome Stable + purge all the things
RUN mkdir -p /etc/apt/keyrings
RUN apt-get update
RUN apt-get install -y \
	apt-transport-https \
    --no-install-recommends
RUN apt-get install -y ca-certificates \
	curl \
	gnupg \
    --no-install-recommends
RUN apt-get install	-y fonts-takao \
    fonts-arphic-uming \
    fonts-arphic-ukai \
    fonts-wqy-zenhei \
    fonts-alee \
    fonts-unfonts-extra \
	unzip \
	wget \
	--no-install-recommends
RUN curl -sS -o - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/apt/keyrings/google-chrome.gpg
RUN  ls -la /etc/apt/keyrings/google-chrome.gpg
RUN  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
    > /etc/apt/sources.list.d/google-chrome.list \
	&& apt-get update && apt-get install -y \
	google-chrome-stable
RUN	apt-get purge --auto-remove -y curl \
	&& rm -rf /var/lib/apt/lists/*

# Add a chrome user and setup home dir.
RUN groupadd --system chrome && \
    useradd --system --create-home --gid chrome --groups audio,video chrome && \
    mkdir --parents /home/chrome/reports && \
    chown --recursive chrome:chrome /home/chrome

USER chrome

EXPOSE 9515

ENTRYPOINT [ "google-chrome-stable  --disable-gpu --headless --remote-debugging-address=0.0.0.0 --window-size=1920,1080 --remote-debugging-port=9222" ]

#TODO Remove the logging and verbosity
CMD [ "--log-path=/tmp/chromedriver.log", "--verbose", "--allowed-ips=", "--allowed-origins=*" ]
