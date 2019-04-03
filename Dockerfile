FROM python:3.5

RUN apt-get update && apt-get upgrade -y && \
    pip install --upgrade pip

ENV PHANTOM_JS "phantomjs-2.1.1-linux-x86_64"
RUN wget https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_JS.tar.bz2
RUN tar xvjf $PHANTOM_JS.tar.bz2
RUN mv $PHANTOM_JS /usr/local/share
RUN ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin

WORKDIR /usr/src/app
RUN mkdir output cache
VOLUME ["/usr/src/app/output", "/usr/src/app/cache"]

COPY ./config/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt && \
    rm requirements.txt

COPY ./src/* ./

RUN flake8 ./*

CMD ["./run"]
