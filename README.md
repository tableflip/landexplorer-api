# inspire-api
:world_map: An experimental graphql api for finding an INSPIRE ID for a given lat/lng.

**Installing & Running the server**

Run the following commands to install and start the service

```sh
npm install && npm start
```

**Usage**

For working with the API you can start a dev server that will restart the server after changes using:

```
npm run watch
```

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

**Running the tests**

To run the tests you will need to create a database in postgres like this:

`CREATE DATABASE inspire_tests;`

Then connect to `inspire_tests` database using `\CONNECT inspire_tests;`

Now extend the schema definition of inspire_tests to include geometry by using:

`CREATE EXTENSION postgis;`

To seed the database requires you to have GDAL installed with a Postgres driver

`brew install gdal --with-postgresql`

You can then seed the database by Running

```
npm run seed
```
