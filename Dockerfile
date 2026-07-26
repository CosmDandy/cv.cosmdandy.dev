FROM debian:12-slim

ARG INTER_VERSION=4.1

# uid/gid 1001 — под ними GitHub-hosted runner (пользователь `runner`) создаёт
# рабочий каталог, который монтируется в контейнер job'ы как /__w. Если id не
# совпадут, непривилегированный пользователь не сможет писать в workspace и
# checkout упадёт на правах.
ARG APP_UID=1001
ARG APP_GID=1001

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
    mkdir -p /usr/share/texlive/texmf-dist/tex/latex/moresize

# latex moresize.ins пишет .sty в текущий каталог, поэтому в него надо зайти.
# Каталог задаём WORKDIR, а не `RUN cd ...` (DS-0013): `cd` внутри RUN живёт
# только до конца строки и молча теряется при правке соседних команд.
WORKDIR /tmp/moresize/moresize
RUN latex moresize.ins && \
    cp moresize.sty /usr/share/texlive/texmf-dist/tex/latex/moresize/ && \
    texhash

# Сбрасываем workdir до следующего RUN и убираемся уже из него: buildkit
# пересоздаёт отсутствующий WORKDIR перед каждым шагом, поэтому удаление
# /tmp/moresize внутри предыдущего RUN тут же откатывалось пустым каталогом.
WORKDIR /

# Install Inter font
RUN rm -rf /tmp/moresize /tmp/moresize.zip && \
    wget -q "https://github.com/rsms/inter/releases/download/v${INTER_VERSION}/Inter-${INTER_VERSION}.zip" -O /tmp/inter.zip && \
    mkdir -p /usr/share/fonts/inter && \
    unzip -q /tmp/inter.zip -d /tmp/inter && \
    cp /tmp/inter/extras/ttf/Inter-*.ttf /usr/share/fonts/inter/ && \
    fc-cache -f && \
    rm -rf /tmp/inter /tmp/inter.zip

# Непривилегированный пользователь: root в контейнере — это root на хосте при
# любом побеге из namespace, а собирать PDF из-под него незачем (DS-0002).
RUN groupadd -g "${APP_GID}" app && \
    useradd -m -u "${APP_UID}" -g "${APP_GID}" -s /bin/bash app && \
    mkdir -p /workspace && \
    chown -R "${APP_UID}:${APP_GID}" /workspace

WORKDIR /workspace
USER app

# Образ одноразовый (job-контейнер CI), долгоживущего процесса в нём нет,
# поэтому HEALTHCHECK проверяет не сервис, а целостность тулчейна: так
# «пустой» образ после неудачной пересборки не притворится рабочим (DS-0026).
HEALTHCHECK --interval=5m --timeout=30s --start-period=5s --retries=1 \
    CMD latexmk --version > /dev/null 2>&1 && \
        python3 -c "import yaml, jinja2" || exit 1
