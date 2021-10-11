---
title: "Cloud Application #1 A) Build your own Node.js Microservice"
categories:
  - Microservices
tags:
  - Dev
  - Node.JS
  - Cloud Application
---
## Prerequisites
- installed Node.js and Npm 
- basic knowledge of JavaScript and Node.js
- enjoy programming

## Preparations
In this part we will create our base project, remove unused files and install all necessary dependencies which we will work with later.
First of all we need the express generator, which gives us a basic structure for our application:
``npm install express-generator -g``. Now we can build our application: ``express --no-view yourApplicationName``
Now the following structure should have been created:
```
   yourApplicationName\
    |-- \public\
    |  |-- \javascripts\
    |  |-- \images\
    |  |-- \stylesheets\
    |  |-- |--\style.css
    |--|-- \index.html
    |-- \routes\
    |  |-- \index.js
    |  |-- \users.js
    |-- \app.js
    |-- \package.json
    |-- \bin\www                     
```
From the automatically generated files we can delete the folders public and routes, cause we don´t need them.
Next we need to install 2 packages which we need for connecting to the database (mysql) through our application:
```python
#switch to your application folder
cd yourApplicationName
#installs the missing dependencies, which are already declared at package.json
npm install 
npm install mysql
#only needed if you have a timestamp field
npm install momentum
```
	*What you can optionally install is **nodemon**: **"Monitor for any changes in your node.js application and automatically restart the server - perfect for development"** you could start your Application with nodemon app.js instead of npm start*
Now we have prepared everything so far to start with the implementation of our service.

## Build our Service
First we open, with the IDE of yourchoice, the ``app.js`` and remove there the lines 6,7,15, 17 and 18, cause our application could not start with these (we already removed the files for this lines of code).
Now our ``app.js``  should look like this:
```javascript
var express  = require('express');
var path = require('path');
var cookieParser =  require('cookie-parser');
var logger =  require('morgan');  

var app = express();

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended:  false }));
app.use(cookieParser());

module.exports = app;
```
To validate that our application is running, we can insert a simple ``console.log("Hello World");``  in the line before ``module.exports = app;``.
Now we can start our application for the first time, either with ``npm start``  or with ``nodemon ./bin/www`` (if it is installed).
*I prefer nodemon because this way we start the application only once and everytime when we edit our code, the changes will be applied automatically.* #**hotreloading**
If everything works well, we now receive "Hello World".
Fine.
As a next step we want to display "Hello World" at our Browser.
For that, we want to implement an Express Route, which listen on the path "/", use an HTTP-GET method and sends us as response "Hello World".

```javascript
app.get('/', (request, response) => {
	response.send("Hello World");
});
```
If you know open your Browser and type "localhost:3000/" you should see there "Hello World". 
*Info: Instead of the GET method ( ``app.get('/', (req, res) => {});`` you can also use all other HTTP methods ( app.post, app.put, app.delete)*

Now we need 3 routes for our Microservice -> ``insert`` ``getAll`` ``getByName``. I have decided that all 3 will be a normal GET-Method. The reson for that is, you can simply call them using your browser and you don't have to install any other programs (like curl, postman etc.). *For "insert" POST would also be a good choice.* 

```javascript
app.get('/insert', (request, response) => {
	response.send("insert something to our mysql table");
});
app.get('/getByName/:name', (request, response) => {
	response.send("show only entry for: " + request.params.name);
});
app.get('/getAll', (request, response) => {
	response.send("show all entries");
});
/** optional method to check if our microservice is running
app.get('/health', (request, response) => {
	response.send("everything is fine");
});
**/
```
You will now notice a special detail in the routes. "*getByName*" still has the parameter :name by this syntax we can pass parameters directly to the path and the route will only take effect if ``/getByName/`` has a value afterwards. This way we save a Null check. 
We can access the URL parameters as follows:
```javascript
request.params.yourParam 	->	defined in the route ( /:yourParam/:yourParam2
request.query.yourQuery		-> 	defined in the url	 ( /get?yourQuery=1234&yourQuery2=1)
request.body.yourParam		-> 	is often used by POST-Methods
```
Up to this point we already have a microservice which provides us with mocked answers and integrated hotreloading. The last step is to access the data from the database.

## Connect to the Database
In addition to routing to path XYZ, we also need a database from which we load / save the corresponding data. For this I simply used a MySQL (at remotemysql.com there are e.g. free databases).
In our Preparations we have already installed the Momentum and Mysql dependencies for nodejs. Info: *Momentum is only needed to create a valid timestamp (so if you don't need a timestamp - you don't have to install it).*
First we import our packages:
``` javascript
var mysql = require('mysql');
var momentum = require('momentum');
```
The next step is to create a global variable for the connection below the import section:
```
var connection = mysql.createConnection({
	host: "localhost",
	// never save credentials to your source code, store them in environment variables!
	user: process.env.dbUser,
	password: process.env.dbPassword, 
	database: "examples"
}
```
If your database is running and you can access them with your user without any problems, everything should works! Next we will implement the ``getAll`` method. For that, we will replace the existing code with the following one: 
```javascript
// http://localhost:3000/getAll
app.get('/getAll', (request, response) => {
	connection.query("SELECT * FROM someTable", function (err, result, fields) {
		if (err) return response.send(err);
		return response.json(result);
	});
});
```
We now send the query "``SELECT * FROM someTable``" from our microservice to our database, should any SQL errors occur because e.g. the table / database does not exist or something else - we send the error als response otherwise, If everything works, we send a json with the data as answer.

Next, we implement the ``/getByName/:name`` Method:
```javascript
// http://localhost:3000/getByName/data
app.get('/getByName/:name', (req, res) => {
	con.query("SELECT * FROM someTable WHERE name = " + mysql.escape(req.params.name), function (err, result, fields) {
		if (err) return res.send(err);
		return res.json(result);
	});
});
```
Info: *When query values are variables provided by the user, you should escape the values, like that "mysql.escape( )" otherwise you risk a sql injection.*
Finally we create our insert function:
```javascript
app.get('/insert', (req, res) => {
	if(typeof req.query.name !== 'undefined' && typeof req.query.text !== 'undefined' && typeof req.query.description !== 'undefined') {
		var sql = "INSERT INTO someTable (uid, timestamp, name, text, description ) VALUES ?";
		var values = [[uuidv4(), moment().utc().format("YYYY-MM-DD"), req.query.name, req.query.text, req.query.description ]]
		con.query(sql, [values] ,function (err, result) {
			if (err) return res.send(err);
			return res.send("insert successfully: " + result);
		});
	}
});

// generates a uuid
function uuidv4() {
	return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
		var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
		return v.toString(16);
	});
}
```
Here we first ask if all query parameters are existing. Then we create our SQL statement and pass the required values to con.query as second parameter.

That would be it. Now we have a running MicroService, which retrieves data from a MySQL and provides them as JSON via the endpoints.
Your app.js should now look like this:
```javascript
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
var mysql = require('mysql');
var moment = require('moment');

var app = express();

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());

var con = mysql.createConnection({
	host: "localhost",
	user: process.env.dbUser,
	password: process.env.dbPassword,
	database: "examples"
});

// http://localhost:3000/insert?name=someText&text=irgendein&description=lol
app.get('/insert', (req, res) => {
	if(typeof req.query.name !== 'undefined' && typeof req.query.text !== 'undefined' && typeof req.query.description !== 'undefined') {
		var sql = "INSERT INTO someTable (uid, timestamp, name, text, description ) VALUES ?";
		var values = [[uuidv4(), moment().utc().format("YYYY-MM-DD"), req.query.name, req.query.text, req.query.description ]]
		con.query(sql, [values] ,function (err, result) {
			if (err) return res.send(err);
			return res.send("insert successfully: " + result);
		});
	}
});

// http://localhost:3000/getByName/data
app.get('/getByName/:name', (req, res) => {
	con.query("SELECT * FROM someTable WHERE name = " + mysql.escape(req.params.name), function (err, result, fields) {
		if (err) return res.send(err);
		return res.json(result);
	});
});

// http://localhost:3000/getAll
app.get('/getAll', (req, res) => {
	con.query("SELECT * FROM someTable", function (err, result, fields) {
		if (err) return res.send(err);
		return res.json(result);
	});
});

// generates a uuid
function uuidv4() {
	return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
		var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
		return v.toString(16);
	});
}

module.exports = app;
```


### Next Step:   [Dockerizing our Service](https://whit-e.com/articles/dockerizing-our-service)

***Info**/ **best practice**: Why should I always check the database for each request? Just create a **cache**. When the server starts or adds data to the database, it is filled with data. Advantage: significantly less load on the system and your database*

#### Project: [GitHub: microservice_blueprint_nodejs](https://github.com/whit-e/microservice_blueprint_nodejs)
