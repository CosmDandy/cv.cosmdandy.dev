FROM debian:12-slim

ARG INTER_VERSION=4.1

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-lang-cyrillic \
    texlive-plain-generic \
    latexmk \
    python3 \
    python3-yaml \
    python3-jinja2 \
    poppler-utils \
    libwebp-dev \
    webp \
    wget \
    unzip \
    fontconfig \
    ca-certificates \
    git && \
    rm -rf /var/lib/apt/lists/*

# Install fontawesome5 and moresize from CTAN (avoids texlive-fonts-extra ~400MB)
RUN wget -q https://mirrors.ctan.org/fonts/fontawesome5.zip -O /tmp/fa5.zip && \
    unzip -q /tmp/fa5.zip -d /tmp/fa5 && \
    cp -r /tmp/fa5/fontawesome5/tex/* /usr/share/texlive/texmf-dist/tex/latex/ && \
    mkdir -p /usr/share/texlive/texmf-dist/fonts/opentype/fontawesome5 && \
    cp /tmp/fa5/fontawesome5/opentype/*.otf /usr/share/texlive/texmf-dist/fonts/opentype/fontawesome5/ && \
    rm -rf /tmp/fa5 /tmp/fa5.zip && \
    wget -q https://mirrors.ctan.org/macros/latex/contrib/moresize.zip -O /tmp/moresize.zip && \
    unzip -q /tmp/moresize.zip -d /tmp/moresize && \
    mkdir -p /usr/share/texlive/texmf-dist/tex/latex/moresize && \
    cd /tmp/moresize/moresize && latex moresize.ins && \
    cp /tmp/moresize/moresize/moresize.sty /usr/share/texlive/texmf-dist/tex/latex/moresize/ && \
    rm -rf /tmp/moresize /tmp/moresize.zip && \
    texhash

# Install Inter font
RUN wget -q "https://github.com/rsms/inter/releases/download/v${INTER_VERSION}/Inter-${INTER_VERSION}.zip" -O /tmp/inter.zip && \
    mkdir -p /usr/share/fonts/inter && \
    unzip -q /tmp/inter.zip -d /tmp/inter && \
    cp /tmp/inter/extras/ttf/Inter-*.ttf /usr/share/fonts/inter/ && \
    fc-cache -f && \
    rm -rf /tmp/inter /tmp/inter.zip

WORKDIR /workspace
