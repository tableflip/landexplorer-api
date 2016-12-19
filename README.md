# inspire-api
:world_map: An experimental graphql api for finding an INSPIRE ID for a given lat/lng

**Installing & Running the server**

Run the following commands to install and start the service

```sh
npm install && npm start
```

**Usage**

There is a graphical interface that you can use to test your queries. visit [localhost:8080/graphiql](http://localhost:8080/graphiql) and type in the following:

```
{
  inspireId(lng: "-1.25390", lat: "51.76110")
}
```
The service will return your inspireId for that lng lat
```
{
  "data": {
    "inspireId": "27567047"
  }
}
```
