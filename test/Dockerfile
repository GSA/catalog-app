FROM ubuntu:bionic

RUN apt-get update && apt-get install -y python-dev python-virtualenv xvfb sudo
RUN apt-get install -y fonts-ipafont-gothic xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic
RUN apt-get install -y supervisor
#RUN apt-get install -y firefox-geckodriver chromium-chromedriver

# chromedriver does not like to run as root.
RUN useradd --create-home --home /app --groups audio,video app

RUN echo 'app ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/app

USER app
WORKDIR /app
COPY requirements.txt /app/
COPY entrypoint.sh /
RUN virtualenv .venv
RUN /app/.venv/bin/pip install -r requirements.txt
RUN /app/.venv/bin/seleniumbase install chromedriver latest
RUN /app/.venv/bin/seleniumbase install geckodriver latest

COPY *.py /app/

ENV DISPLAY=:99
ENV BROWSER=chrome
ENTRYPOINT ["/entrypoint.sh"]
#CMD ["pytest", "--browser=$BROWSER"]
CMD pytest --browser=$BROWSER
