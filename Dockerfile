# Builder image
FROM --platform=$BUILDPLATFORM golang:1.17.1-bullseye AS build
ENV GOPATH /go
WORKDIR /go/src/headscale
ARG TARGETOS TARGETARCH BUILDPLATFORM

COPY go.mod go.sum /go/src/headscale/
RUN go mod download

COPY . .

#RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go install -a -ldflags="-extldflags=-static" -tags netgo,sqlite_omit_load_extension ./cmd/headscale
#RUN if [ ${BUILDPLATFORM} = ${TARGETOS}/${TARGETARCH} ]; then test -e /go/bin/headscale; else test -e /go/bin/${TARGETOS}_${TARGETARCH}/headscale; fi
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /headscale -a -ldflags="-extldflags=-static" -tags netgo,sqlite_omit_load_extension ./cmd/headscale
RUN test -e /headscale

# Production image
FROM gcr.io/distroless/base-debian11

#COPY --from=build /go/bin/headscale /bin/headscale
COPY --from=build /headscale /bin/headscale
ENV TZ UTC

EXPOSE 8080/tcp
CMD ["headscale"]
