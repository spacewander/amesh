# Copyright 2022 The Amesh Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
FROM golang:1.16.5 as amesh-sidecar-build-stage

ARG ENABLE_PROXY=false
WORKDIR /amesh

COPY go.* ./
RUN if [ "$ENABLE_PROXY" = "true" ]; then go env -w GOPROXY=https://goproxy.cn,direct ; fi \
    && go mod download

COPY Makefile Makefile
COPY cmd/sidecar cmd/sidecar
COPY pkg/ pkg/
RUN if [ "$ENABLE_PROXY" = "true" ]; then go env -w GOPROXY=https://goproxy.cn,direct ; fi \
    && make build-amesh-sidecar

FROM centos:7

WORKDIR /usr/local/amesh

COPY --from=amesh-sidecar-build-stage /amesh/bin/amesh-sidecar ./

#COPY ./bin/amesh-sidecar .

ENTRYPOINT ["/usr/local/amesh/amesh-sidecar"]
