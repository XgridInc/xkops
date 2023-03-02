FROM ubuntu:22.04

COPY src /src
COPY Makefile /

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN apt-get update && \
     apt-get install -y make=4.3-4.1build1 --no-install-recommends  && \
     apt-get install -y curl=7.81.0-1ubuntu1.8 --no-install-recommends  && \
     apt-get install -y --no-install-recommends ca-certificates=20211016ubuntu0.22.04.1 curl=7.81.0-1ubuntu1.8 && \
     apt-get upgrade -y && \
     apt-get clean && \
     rm -rf /var/lib/apt/lists/*y && \
     curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
     chmod +x ./kubectl && \
     mv ./kubectl /usr/local/bin/kubectl && \
     apt-get install -y unzip=6.0-26ubuntu3.1 --no-install-recommends && \
     apt-get install -y jq=1.6-2.1ubuntu3 --no-install-recommends && \
     export PATH="/usr/local/bin:$PATH" && \
     apt-get install -y python3-pip=22.0.2+dfsg-1ubuntu0.2 --no-install-recommends && \
     chmod -R +x /src  

CMD [ "make", "all" ]
