FROM ubuntu:14.04

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y curl

ADD ./test.sh /usr/local/bin/test.sh

CMD ["test.sh"]
