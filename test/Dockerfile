FROM ubuntu:bionic

RUN apt-get update && apt-get install -y python-dev python-virtualenv chromium-chromedriver

WORKDIR /app
COPY requirements.txt /app/
COPY entrypoint.sh /
RUN virtualenv .venv
RUN /app/.venv/bin/pip install -r requirements.txt
#RUN /app/.venv/bin/seleniumbase install chromedriver latest

COPY *.py /app/

ENTRYPOINT ["/entrypoint.sh"]
CMD ["pytest"]
