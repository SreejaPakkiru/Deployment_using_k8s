FROM ubuntu:22.04

RUN apt-get update -y && \
    apt-get install -y curl bash && \
    apt-get clean && \
    mkdir -p /tests

COPY smoke-test.sh /tests/
COPY integration-test.sh /tests/
COPY run-tests.sh /tests/

RUN chmod 777 /tests/*.sh

WORKDIR /tests

ENTRYPOINT ["/tests/run-tests.sh"]
