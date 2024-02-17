FROM python

ARG CHROMEVERSION
ARG CHROMEURL

ENV MSR_CHROMEVERSION=$CHROMEVERSION
ENV CHROMEDLURL=$CHROMEURL

# download and install google chrome and xvfb
RUN wget -O /tmp/chrome.deb $CHROMEDLURL
RUN apt-get update && apt-get install -y /tmp/chrome.deb xvfb
RUN google-chrome --version

# create the app directory
WORKDIR /app

# clone the project
RUN git clone https://github.com/klept0/MS-Rewards-Farmer.git ./

# install dependencies
RUN pip install --root-user-action=ignore -r requirements.txt

# setting display enviroment stuff
ENV DISPLAY=:99
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null

RUN sed -i "s|download_url = \"https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/%s/%s/%s\"|download_url = \"https://storage.googleapis.com/chrome-for-testing-public/%s/%s/%s\"|g" /usr/local/lib/python3.10/dist-packages/undetected_chromedriver/patcher.py

# copy entrypoint script
COPY entrypoint.sh ./

ENTRYPOINT ["/app/entrypoint.sh"]

CMD ["python3", "main.py"]
