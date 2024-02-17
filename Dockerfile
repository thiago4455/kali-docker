FROM kalilinux/kali-rolling:arm64
SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt -y install ca-certificates
RUN apt-get update && apt -y install wget iputils-ping git vim nano curl nmap openvpn cmake bat

WORKDIR /tmp
RUN wget https://go.dev/dl/go1.22.0.linux-arm64.tar.gz
RUN tar -C /usr/local -xzf go1.22.0.linux-arm64.tar.gz
RUN cp /usr/local/go/bin/go /usr/bin
ENV GOROOT="/usr/local/go"
ENV GOPATH="$HOME/go"
ENV PATH="$GOPATH/bin:$GOROOT/bin:$HOME/.local/bin:$PATH"

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
RUN go install github.com/tomnomnom/httprobe@latest
RUN go install github.com/tomnomnom/meg@latest
RUN go install github.com/tomnomnom/hacks/html-tool@latest
RUN go install github.com/tomnomnom/unfurl@latest
RUN go install github.com/tomnomnom/gron@latest
RUN go install github.com/tomnomnom/anew@latest
RUN go install github.com/tomnomnom/gf@latest
RUN go install github.com/tomnomnom/hacks/html-tool@latest
RUN go install github.com/tomnomnom/comb
RUN cp -r $GOPATH/pkg/mod/github.com/tomnomnom/gf@*/examples ~/.gf
RUN echo 'source $GOPATH/pkg/mod/github.com/tomnomnom/gf@*/gf-completion.bash' >> ~/.bashrc

RUN apt -y install freerdp2-x11 rdesktop nbtscan xclip
RUN ln -s /usr/bin/batcat /usr/local/bin/bat
COPY configs/bat.cfg /root/.config/bat/config

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
#RUN cargo install rustscan
RUN apt -y install enum4linux

RUN apt -y install python3 python3-pip
RUN pip3 install dnsgen
RUN mkdir -p /usr/share/xsstrike && git clone https://github.com/s0md3v/XSStrike /usr/share/xsstrike
RUN chmod +x /usr/share/xsstrike/xsstrike.py && ln -s /usr/share/xsstrike/xsstrike.py /usr/bin/xsstrike

RUN apt -y install gospider sqlmap

RUN echo "printf '\eP\$f{\"hook\": \"SourcedRcFileForWarp\", \"value\": { \"shell\": \"bash\" }}\x9c'" >> /root/.bashrc

WORKDIR /work
ENV HISTFILE=/work/.bash_history
ENV TERM=xterm-256color
