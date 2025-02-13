FROM onosproject/golang-build:v0.6.10 as build

ARG LOCAL_AETHER_MODELS

ENV ADAPTER_ROOT=$GOPATH/src/github.com/onosproject/subscriber-proxy
ENV CGO_ENABLED=0

RUN mkdir -p $ADAPTER_ROOT/

COPY . $ADAPTER_ROOT/

# If LOCAL_AETHER_MODELS was used, then patch the go.mod file to load
# the models from the local source.
RUN if [ -n "$LOCAL_AETHER_MODELS" ] ; then \
    echo "replace github.com/onosproject/config-models/modelplugin/aether-3.0.0 => ./local-aether-models/aether-3.0.0" >> $ADAPTER_ROOT/go.mod; \
    echo "replace github.com/onosproject/config-models/modelplugin/aether-4.0.0 => ./local-aether-models/aether-4.0.0" >> $ADAPTER_ROOT/go.mod; \
    fi

RUN cat $ADAPTER_ROOT/go.mod


RUN cd $ADAPTER_ROOT && GO111MODULE=on go build -o /go/bin/subscriber-proxy ./cmd/subscriber-proxy

FROM alpine:3.11
RUN apk add bash openssl curl libc6-compat

ENV HOME=/home/subscriber-proxy

RUN mkdir $HOME
WORKDIR $HOME

COPY --from=build /go/bin/subscriber-proxy /usr/local/bin/

