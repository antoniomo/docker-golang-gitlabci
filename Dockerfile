FROM golang:1.8.1-alpine
MAINTAINER Antonio Macías Ojeda <antonio.macias.ojeda@gmail.com> (@antoniomo)

ARG GIT
ARG OPENSSH
ARG MAKE
ARG GOMETALINTER
ARG GLIDE

RUN  if [ $GIT ]; then apk add --no-cache git; fi \
	&& if [ $OPENSSH ]; then apk add --no-cache openssh-client; fi \
	&& if [ $MAKE ]; then apk add --no-cache make; fi \
	&& if [ $GOMETALINTER ]; then apk add --no-cache gcc musl-dev \
		&& go get github.com/alecthomas/gometalinter \
		&& gometalinter --install; fi \
	&& if [ $GLIDE ]; then go get github.com/Masterminds/glide; fi
