FROM python

# add google chrome repository
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'

# install required pacakges
RUN apt-get update && apt-get install -y google-chrome-stable xvfb

# create the app directory
WORKDIR /app

# clone the project
RUN git clone https://github.com/klept0/MS-Rewards-Farmer.git ./

# install dependencies
RUN pip install --root-user-action=ignore -r requirements.txt

# setting display enviroment stuff
ENV DISPLAY=:99
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null

# copy entrypoint script
COPY entrypoint.sh ./

ENTRYPOINT ["/app/entrypoint.sh"]

CMD ["python3", "main.py"]