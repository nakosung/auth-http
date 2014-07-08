FROM dockerfile/nodejs

RUN npm i coffee-script -g
ADD . /app
WORKDIR /app
RUN npm i

ENTRYPOINT coffee .