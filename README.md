auth-http
=========

basic everyauth 

This app lacks of conf.coffee (which contains some secret infos including github app ids...)

```
docker run -e MONGO_IP=__your_mongo_ip__ -d -p 3000:3000 \
  -e GITHUB_APPID=__your_github_appid__ -e GITHUB_SECRET=__your_github_secret__ \
  nakosung/auth-http
```

dependencies
------------

Express 4.x, everyauth
