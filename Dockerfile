FROM clearlinux:base as builder

ARG IOZONE_VERSION=LATEST
ARG TARGET=linux-AMD64

RUN swupd bundle-add \
	c-basic \
	python3-basic

COPY requirements.txt .
RUN pip install -U pip-tools && \
	pip-sync

WORKDIR /src
COPY download.py .
RUN python download.py && \
	tar -xf iozone3_*.tar && \
	pushd iozone3_*/src/current && \
	make ${TARGET} && \
	mkdir /build && \
	cp iozone /build

COPY entrypoint.sh /build


FROM clearlinux:base
ENV DATA_DIR=/data
RUN swupd bundle-add su-exec && \
	swupd clean
COPY --from=builder /build/iozone /build/entrypoint.sh .
WORKDIR "${DATA_DIR}"
ENTRYPOINT ["/entrypoint.sh", "/iozone"]
CMD ["-a"]
