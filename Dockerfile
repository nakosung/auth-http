FROM dockerfile/nodejs

RUN npm i coffee-script -g
ADD . /app
WORKDIR /app

ENTRYPOINT coffee .