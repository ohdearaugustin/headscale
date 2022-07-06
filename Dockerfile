# Builder image
FROM --platform=$BUILDPLATFORM docker.io/golang:1.18.0-bullseye AS build
ARG VERSION=dev
ENV GOPATH /go
WORKDIR /go/src/headscale

COPY go.mod go.sum /go/src/headscale/
RUN go mod download

COPY . .
ARG TARGETOS TARGETARCH
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /go/bin/headscale -ldflags="-s -w -X github.com/juanfont/headscale/cmd/headscale/cli.Version=$VERSION" -a ./cmd/headscale 
RUN test -e /go/bin/headscale

# Production image
FROM gcr.io/distroless/base-debian11

COPY --from=build /go/bin/headscale /bin/headscale
ENV TZ UTC

EXPOSE 8080/tcp
CMD ["headscale"]
