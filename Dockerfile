# Copyright (c) 2023, Xgrid Inc, https://xgrid.co

# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:22.10

COPY src /src
COPY Makefile /

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN apt-get update && \
     apt-get install -y make=4.3-4.1build1 --no-install-recommends  && \
     apt-get install -y curl=7.81.0-1ubuntu1.10 --no-install-recommends  && \
     apt-get install -y --no-install-recommends ca-certificates curl=7.81.0-1ubuntu1.10 && \
     apt-get upgrade -y && \
     apt-get clean && \
     rm -rf /var/lib/apt/lists/*y && \
     curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
     chmod +x ./kubectl && \
     mv ./kubectl /usr/local/bin/kubectl && \
     apt-get install -y unzip=6.0-26ubuntu3.1 --no-install-recommends && \
     apt-get install -y jq=1.6-2.1ubuntu3 --no-install-recommends && \
     export PATH="/usr/local/bin:$PATH" && \
     chmod -R +x /src

CMD [ "make", "all" ]
