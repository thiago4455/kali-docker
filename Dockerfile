FROM kalilinux/kali-rolling:arm64
SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt -y install ca-certificates
RUN apt-get update && apt -y install wget iputils-ping git vim nano curl nmap openvpn cmake bat gnupg gpg xclip python3 python3-pip iproute2 netcat-traditional fzf
RUN apt -y install rdesktop nbtscan enum4linux gospider sqlmap jq chromium feh metasploit-framework

RUN pip3 install dnsgen uddup --break-system-packages

WORKDIR /tmp

## GO
RUN wget https://go.dev/dl/go1.22.0.linux-arm64.tar.gz
RUN tar -C /usr/local -xzf go1.22.0.linux-arm64.tar.gz
RUN cp /usr/local/go/bin/go /usr/bin
ENV GOROOT="/usr/local/go"
ENV GOPATH="/etc/go"
ENV PATH="$GOPATH/bin:$GOROOT/bin:$PATH"

RUN go install -v github.com/owasp-amass/amass/v4/...@master
COPY configs/amass.ini "$HOME/.config/amass/config.ini"
RUN GO111MODULE=on go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
# COPY configs/subfinder_provider_config.yaml "$HOME/.config/subfinder/provider-config.yaml"
RUN go install github.com/lc/gau/v2/cmd/gau@latest
RUN go install github.com/ffuf/ffuf@latest
RUN go install github.com/projectdiscovery/httpx/cmd/httpx@latest
RUN go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

#tomnomnom Tools
RUN go install github.com/tomnomnom/assetfinder/...@master
RUN go install github.com/tomnomnom/waybackurls/...@master
RUN go install github.com/tomnomnom/httprobe@master
RUN go install github.com/tomnomnom/meg@latest
RUN go install github.com/tomnomnom/hacks/html-tool@latest
RUN go install github.com/tomnomnom/unfurl@latest
RUN go install github.com/tomnomnom/gron@latest
RUN go install github.com/tomnomnom/anew@latest
RUN go install github.com/tomnomnom/gf@latest
RUN go install github.com/tomnomnom/hacks/html-tool@latest
RUN go install github.com/tomnomnom/comb@latest
RUN go install github.com/tomnomnom/fff@latest
RUN cp -r $GOPATH/pkg/mod/github.com/tomnomnom/gf@*/examples ~/.gf
RUN echo 'source $GOPATH/pkg/mod/github.com/tomnomnom/gf@*/gf-completion.bash' >> ~/.bashrc

## RUST
#RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
#RUN cargo install rustscan


## NESSUS
RUN curl --request GET \
  --url 'https://www.tenable.com/downloads/api/v2/pages/nessus/files/Nessus-10.8.3-ubuntu1804_aarch64.deb' \
  --output 'Nessus-10.8.3-ubuntu1804_aarch64.deb'
RUN apt -y install /tmp/Nessus-10.8.3-ubuntu1804_aarch64.deb
RUN echo "alias nessus=\"/etc/init.d/nessusd start\"" >> ~/.bashrc


RUN wget https://github.com/PowerShell/PowerShell/releases/download/v7.4.4/powershell-7.4.4-linux-arm64.tar.gz && \
  mkdir -p /opt/microsoft/powershell/7 && \
  tar zxf /tmp/powershell-7.4.4-linux-arm64.tar.gz -C /opt/microsoft/powershell/7 && \
  chmod +x /opt/microsoft/powershell/7/pwsh && \
  ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh


RUN apt -y install ninja-build build-essential git-core debhelper cdbs dpkg-dev cmake cmake-curses-gui clang-format ccache opencl-c-headers ocl-icd-opencl-dev libmp3lame-dev libopus-dev libsoxr-dev libpam0g-dev pkg-config xmlto libssl-dev docbook-xsl xsltproc libxkbfile-dev libx11-dev libwayland-dev libxrandr-dev libxi-dev libxrender-dev libxext-dev libxinerama-dev libxfixes-dev libxcursor-dev libxv-dev libxdamage-dev libxtst-dev libcups2-dev libpcsclite-dev libasound2-dev libpulse-dev libgsm1-dev libusb-1.0-0-dev uuid-dev libxml2-dev libfaad-dev libfaac-dev libsdl2-dev libsdl2-ttf-dev libcjson-dev libpkcs11-helper-dev liburiparser-dev libkrb5-dev libsystemd-dev libfuse3-dev libswscale-dev libcairo2-dev libavutil-dev libavcodec-dev libswresample-dev libpkcs11-helper1-dev
RUN git clone --depth 1 https://github.com/thiago4455/freerdp.git && \
  cmake -GNinja -B freerdp-build -S freerdp -DCMAKE_BUILD_TYPE=Release -DCMAKE_SKIP_INSTALL_ALL_DEPENDENCY=ON -DCMAKE_INSTALL_PREFIX=/opt/freerdp -DWITH_SERVER=ON -DWITH_SAMPLE=ON -DWITH_PLATFORM_SERVER=OFF -DUSE_UNWIND=OFF -DWITH_SWSCALE=OFF -DWITH_FFMPEG=OFF -DWITH_WEBVIEW=OFF && \
  cmake --build freerdp-build && \
  cmake --install freerdp-build && \
  ln -s /opt/freerdp/bin/xfreerdp /usr/bin/xfreerdp

RUN git clone https://github.com/ameenmaali/urldedupe.git
RUN cd urldedupe && cmake CMakeLists.txt && make && mv urldedupe /usr/bin/urldedupe

RUN mkdir -p /usr/share/xsstrike && git clone https://github.com/s0md3v/XSStrike /usr/share/xsstrike
RUN chmod +x /usr/share/xsstrike/xsstrike.py && ln -s /usr/share/xsstrike/xsstrike.py /usr/bin/xsstrike

RUN cd /tmp && wget http://www.inet.no/dante/files/dante-1.4.3.tar.gz && tar -xvzf dante-1.4.3.tar.gz
RUN cd dante-1.4.3 && ./configure --build=aarch64-unknown-linux-gnu && make && make install
COPY configs/sockd.conf /etc/sockd.conf


RUN wget https://raw.githubusercontent.com/lincheney/fzf-tab-completion/master/bash/fzf-bash-completion.sh -O /usr/local/etc/fzf-bash-completion.sh
RUN wget https://github.com/kovidgoyal/kitty/releases/download/v0.35.2/kitten-linux-arm64 -O /usr/bin/kitten && chmod +x /usr/bin/kitten
RUN wget https://raw.github.com/xwmx/nb/master/nb -O /usr/local/bin/nb && chmod +x /usr/local/bin/nb && nb completions install


RUN git clone https://github.com/vim-airline/vim-airline ~/.vim/pack/dist/start/vim-airline
COPY configs/.vimrc /root/.vimrc
COPY configs/.gitconfig /root/.gitconfig

RUN ln -s /usr/bin/batcat /usr/local/bin/bat
COPY configs/bat.cfg /root/.config/bat/config
#RUN echo "printf '\eP\$f{\"hook\": \"SourcedRcFileForWarp\", \"value\": { \"shell\": \"bash\" }}\x9c'" >> /root/.bashrc
COPY configs/id_ed25519 /root/.ssh/id_ed25519
COPY configs/known_hosts /root/.ssh/known_hosts
RUN chmod 600 /root/.ssh/id_ed25519 &&  eval "$(ssh-agent -s)" && ssh-add /root/.ssh/id_ed25519
RUN printf "[safe]\n        directory = /root/.nb/notes" >> ~/.gitconfig

RUN rm -r /tmp/*

WORKDIR /work
ENV HISTFILE=/work/.bash_history
RUN echo "export HISTSIZE=100000" >> ~/.bashrc
RUN echo "export HISTFILESIZE=100000" >> ~/.bashrc
RUN echo "export HISTCONTROL=ignoredups" >> ~/.bashrc
RUN echo "export EDITOR=vim" >> ~/.bashrc
RUN echo "shopt -s histverify" >> ~/.bashrc
RUN echo "source /usr/local/etc/fzf-bash-completion.sh && bind -x '"'"\t"'": fzf_bash_completion'" >> ~/.bashrc
RUN echo 'alias "xcopy=xclip -selection clipboard"' >> ~/.bashrc
RUN echo 'alias "xpaste=xclip -o -selection clipboard > /dev/null && xclip -o -selection clipboard"' >> ~/.bashrc
RUN echo "alias urlencode=\"jq -sRr @uri\"" >> ~/.bashrc
RUN echo 'eval "$(fzf --bash)"' >> ~/.bashrc
ENV TERM=xterm-256color
