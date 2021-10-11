
## Prerequisites
- installed java 8
- installed gradle
- basic knowledge of java and gradle
- ide with gradle support (i use eclipse)
- enjoy programming

## Preparations
In this part we will create our base project, remove unused files and install all necessary dependencies which we will work with later.
First of all we open our IDE (this tutorial is based on eclipse only) and create a ``new`` > `` Gradle Project``.
In the Gradle Setup we give our project a name on the first step (in my case again ``yourApplicationName``). In the next step we leave all settings as they are and click on finish.

Now the following structure should have been created:
```
   yourApplicationName\
    |-- \src\main\java
    |  |-- \(default package)\
    |  |-- |--\Library.java
    |-- \src\test\java
    |  |-- \(default package)\
    |  |-- |--\LibraryTest.java
    |--|-- \index.html
    |-- \gradle\wrapper
    |  |-- \gradle-wrapper.jar
    |  |-- \gradle-wrapper.properties
    |-- \build.gradle
    |-- \gradlew
    |-- \gradlew.bat
    |-- \settings.gradle                     
```
From the automatically generated files we can delete the Files ``Library.java`` and ``LibraryTest.java``, cause we don´t need them.
Next we add all necessary dependencies to our ``build.gradle``:
```gradle
dependencies {
// Use JUnit test framework
testImplementation 'junit:junit:4.12'

// Jetty
compile group: 'org.eclipse.jetty', name: 'jetty-server', version: '9.4.12.v20180830'
compile group: 'org.eclipse.jetty', name: 'jetty-servlet', version: '9.4.12.v20180830'

// Gson - needed for Json
compile group: 'com.google.code.gson', name: 'gson', version: '2.8.5'

// Java API for RESTful Web Services
compile group: 'javax.ws.rs', name: 'javax.ws.rs-api', version: '2.1.1'

// Glassfish
compile group: 'org.glassfish.jersey.containers', name: 'jersey-container-servlet-core', version: '2.27'
compile group: 'org.glassfish.jersey.inject', name: 'jersey-hk2', version: '2.27'

// MySQL Connector
compile group: 'mysql', name: 'mysql-connector-java', version: '8.0.13'
}
```
After updating our gradle project ``right click on the project``>``Gradle``<``Refresh Gradle Project``, everything is now ready to implement the service

## Build our Service
First we create the class SampleDBObj with the following content:
```java
import java.util.Date;
import java.util.UUID;

public class SampleDBObj
{
    private Date timestamp;
    private String uid;
    private String name;
    private String text;
    private String description;

    public SampleDBObj(String name, String text, String description) {
    	this.timestamp = new Date();
    	this.uid = UUID.randomUUID().toString();
    	this.name = name;
    	this.text = text;
    	this.description = description;

    }
    
    public SampleDBObj(Date timestamp, String uid, String name, String text, String description) {
    	this.timestamp = timestamp;
    	this.uid = uid;
    	this.name = name;
    	this.text = text;
    	this.description = description;

    }

	public String toCSVLine() {
		return this.timestamp + "," + this.uid + "," + this.name + "," + this.text + "," + this.description;
	}

	public Date getTimestamp() {
		return timestamp;
	}

	public String getUid() {
		return uid;
	}

	public String getName() {
		return name;
	}

	public String getText() {
		return text;
	}

	public String getDescription() {
		return description;
	}
	
}
```
This class only represents the objects that we will use later for our service.
Next we create our Servlet class. 
This class receives the requests within the web server and processes them. If you don't know exactly what a servlet is, you can find a very good description at Wikipedia: https://en.wikipedia.org/wiki/Java_servlet 
With a Servlet our routes are specified like e.g. "/getAll" and it is said with which HTTP method this is called. Then business logic happens and the client receives a response from the web server.
But now lets create our Servlet-Class, called "SampleServlet.java":
```java
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;

@Path("/")
public class SampleServlet {
	

	// http://localhost:3001/api/v1/someMethod?someParam=name
	@Path("helloWorld")
	@GET //HTTP Method
	@Produces(MediaType.APPLICATION_JSON) // Response Type of the Route (with a REST-API often used e.g. json) 
	public String helloWorld(@QueryParam("someParam") String name) {
		return "My name is: " + name;			
	}	
}

```
Here you can see, our servlet is very simple. It can be reached directly under "/". If we look at the method ``helloWorld`` we see some annotations above the method declaration.
These are used to say under which path (``@Path("pathForTheMethod")``) in the servlet this method is available, which HTTP method (``@GET`` for GET-Method) must be used for the request and which MediaType (`` @Produces(MediaType.APPLICATION_JSON)``) produces the response. 
We also pass a parameter to our method. Through the annotation ``@QueryParam`` our service later knows - this is a query parameter which is passed through the URL.

Everything was still missing to have a really rudimentary MicroService is the Main Class. Our server, where also the servlets are registered. For this we create the class "Service.java". Our service will look like this:
```java
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.ServletHolder;
import org.glassfish.jersey.servlet.ServletContainer;

public class Service {

	public static void main(String[] args) {
		new Service().startup();
	}

	public boolean startup() {
		ServletContextHandler context = new ServletContextHandler(ServletContextHandler.NO_SESSIONS);
		context.setContextPath("/");
		
		Server server = new Server(3001);
		server.setHandler(context);
		
		ServletHolder servlet = context.addServlet(ServletContainer.class, "/service/*");
		servlet.setInitParameter("jersey.config.server.provider.classnames", SampleServlet.class.getCanonicalName());
		
		try {
			server.start();
			return true;
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return false;
	}
}
```
Here we first create a ServletContextHandler, which we need to register our Servlet there. 
Next we tell the ContextHandler to listen to everything under the root path (``setContextPath("/");``). Then we create the web-server with the port and tell the server which handler it should use. After that, we register our service under the path "service".
If we now start our service and call the page http://localhost:3001/service/helloWorld?someParam=Hello+World we should get the following result:
``My name is: Hello World``
If you get that response, everything works! Very good!
Next we extend our servlet with the required methods: ``insert``, ``getByName``, ``getAll`` ``export``. 
Because we implement it in the same way as our Hello World method, I skip the code at this point.

## Versioned API
**Info**: *If you don't have to use a versioned API and want to use only one servlet for your service - you could skip this point*

Now we optimize our service a little bit.
Why? I always prefer a versioned API. Our Service now looks like that:
```java
import java.util.HashMap;
import java.util.Map;

import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.ServletHolder;
import org.glassfish.jersey.servlet.ServletContainer;

public class Service {

	public static void main(String[] args) {
		
		new Service().startup();
	}

	public boolean startup() {
		ServletContextHandler context = new ServletContextHandler(ServletContextHandler.NO_SESSIONS);
		context.setContextPath("/");
		
		Server server = new Server(3001);
		server.setHandler(context);
		
		registerServletsV1(context);
		
		try {
			server.start();
			return true;
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return false;
	}
	
	private void registerServletsV1(ServletContextHandler context) {
		Map<String, Class<?>> mappings = new HashMap<>();
		// name where our servlet is available
		mappings.put("service", SampleServlet.class);
		// api version
		registerServlets(context, "v1", mappings);
	}

	private void registerServlets(ServletContextHandler context, String version,
		Map<String, Class<?>> mappings) {

		for (String key : mappings.keySet()) {
			Class<?> value = mappings.get(key);

			// /api/v1/service/getAll for example
			ServletHolder servlet = context.addServlet(ServletContainer.class, "/api/" + version + "/" + key + "/*");
			servlet.setInitParameter("jersey.config.server.provider.classnames", value.getCanonicalName());
		}
	}
	
}
```
What's new? The ``registerServletsV1`` method and the ``registerServlets`` method.
*registerServletsV1(ServletConetxHandler context)*:
Holds a map with the path (as String) and the servlet (as Class). These are then passed to the method "registerServlets". In addition we also specify here which version it is. (In this case v1). So you could register different servlets for different API versions.

*registerServlets(ServletConetxHandler context, String version, Map<String, Class<?>> mappings)*:
Here all servlets of ``mappings`` for the API version ``String: version`` are registered for the ``context``.
Very simple. And that's all we need for the API versioning. From now on our servlet is available at http://localhost:3001/api/v1/service/helloWorld .

If we want to add another servlet now, we can simply create and pass another one to mappings.put("servletName", Servlet.class) which can be reached e.g. under /health and gives us the health status of the server.


## Connect to the Database
So far we have a versionable API / MicroService which only gives us "static" answers.
To process "real" data we need a database and have to connect our service to it.
For this purpose we first create a MySQL e.g. on remotemysql.com, or locally on our PC.
So that our database contains some data you can simply import this sql: 
[Dump20191012.sql](So%20that%20our%20database%20contains%20some%20data%20you%20can%20simply%20import%20this%20sql:%20https://github.com/whit-e/microservice_blueprint_java/blob/master/resources/Dump20191012.sql)
Now we already have a pool of data.
Only the connection to the database is missing.
For this I like to create a helper class called ``DBUtils``:
```java
import java.io.FileInputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

public class DBUtils {

	private Connection connection;
	private PreparedStatement preparedStatement;
	
	public DBUtils() {
		Properties prop = new Properties();
		try {
			// load config.properties for db credentials
			prop.load(new FileInputStream("src/main/resources/config.properties"));
			// load jdbc driver and start db connection
			// mit "SET GLOBAL time_zone = "+3:00" time_zone bei mysql setzen um keine TimeZone errors zu bekommen
			Class.forName("com.mysql.cj.jdbc.Driver");
			connection = DriverManager.getConnection("jdbc:mysql://" + prop.getProperty("host", "localhost") +  "/"+prop.getProperty("database"), prop.getProperty("user"), prop.getProperty("password", "lol"));
			String query = "INSERT INTO someTable (timestamp, uid, name, text, description) values (?, ?, ?, ?, ?)";
			// preparedStatement benefits: faster, no sql injection is possible
			// must be created once initially with the query and is then only filled with data; this improves performance.
			preparedStatement = connection.prepareStatement(query);
		} catch (IOException e) {
			e.printStackTrace();
		}
		catch (SQLException e) {
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
	}
	
	/**
	 * insert the obj to the database
	 * 
	 * @param SambleDBObj
	 * @throws SQLException
	 */
	public void insert(SampleDBObj obj) throws SQLException {
		preparedStatement.setTimestamp(1, new Timestamp(System.currentTimeMillis()));
		preparedStatement.setString(2, obj.getUid());
		preparedStatement.setString(3, obj.getName());
		preparedStatement.setString(4, obj.getText());
		preparedStatement.setString(5, obj.getDescription());
		preparedStatement.executeUpdate();
	}
	
	/**
	 * 
	 * @return List<SampleDBObj> - return all entrys
	 * @throws SQLException
	 */
	public List<SampleDBObj> getAll() throws SQLException {
		Statement statement = connection.createStatement();
		ResultSet rs = statement.executeQuery("SELECT * FROM someTable");
		List <SampleDBObj> objs = new ArrayList<SampleDBObj>();
		while(rs.next()) {    
			SampleDBObj obj = new SampleDBObj(rs.getDate("timestamp"), rs.getString("uid"), rs.getString("name"), rs.getString("text"), rs.getString("description"));
			objs.add(obj);
		}
		return objs;
	}

	/**
	 * 
	 * @return SampleDBObj - return specific entry by name
	 * @throws SQLException
	 */
	public SampleDBObj getByName(String name) throws SQLException {
		PreparedStatement statement = connection.prepareStatement("SELECT * FROM someTable WHERE name = ?");
		statement.setString(1, name);
		ResultSet rs = statement.executeQuery();
		if(rs.next()) {
			return new SampleDBObj(rs.getDate("timestamp"), rs.getString("uid"), rs.getString("name"), rs.getString("text"), rs.getString("description"));
		}
		return null;
	}
}
```
I think what the class is doing should be relatively clear. In the constructor we load the file src/main/resources/config.properties which looks like this: 
```
host = localhost
database = examples
user = serviceuser
```


We connect to our Database and create our preparedStatement for the insert route once.
Then we have for all our routes (``insert``, ``getByName``, ``getAll``) a corresponding method which e.g. loads the corresponding data via select or insert statement or adds it to the table.
As a last step we only have to connect our DBUtils for each route with the SampleServlet so that the corresponding data is loaded from the database and written into the response:
```java
import java.lang.reflect.Field;
import java.sql.SQLException;
import java.util.Date;
import java.util.List;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import org.eclipse.jetty.util.StringUtil;

import com.google.gson.Gson;


@Path("/")
public class SampleServlet {
	
	private DBUtils databaseUils;
	
	public SampleServlet() {
		databaseUils = new DBUtils();
	}

	// http://localhost:3001/api/v1/service/insert
	@Path("insert")
	@GET
	@Produces(MediaType.APPLICATION_JSON)
	public Response insert(
			@QueryParam("name") String name,
			@QueryParam("text") String text,
			@QueryParam("description") String description){

		if(StringUtil.isNotBlank(name) && StringUtil.isNotBlank(text) && StringUtil.isNotBlank(description)) {
			SampleDBObj someObj = new SampleDBObj(name, text, description);
			try {
				databaseUils.insert(someObj);
				return Response.ok("Obj successfully created").build();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				return Response.status(404, "An error occurred while calling the service, please try again. \r\n" + e.getMessage()).build();
			}
		} else {
			return Response.status(404, "Object could not be created, one of the required parameters was empty").build();
		}
	}

	
	// http://localhost:3001/api/v1/service/getByName
	@Path("getByName")
	@GET
	@Produces(MediaType.APPLICATION_JSON)
	public String getByName(@QueryParam("name") String name) {
		if(StringUtil.isNotBlank(name)) {
		try {
			return new Gson().toJson(databaseUils.getByName(name));
		} catch (SQLException e) {
			e.printStackTrace();
			return "An error occurred while calling the service, please try again. \r\n" + e.getMessage();
		}
		} else {
			return new Gson().toJson("Object could not be created, one of the required parameters was empty");
		}
	}
	
	// http://localhost:3001/api/v1/service/getAll
	@Path("getAll")
	@GET
	@Produces(MediaType.APPLICATION_JSON)
	public String get() {
		try {
			return new Gson().toJson(databaseUils.getAll());
		} catch (SQLException e) {
			e.printStackTrace();
			return "An error occurred while calling the service, please try again. \r\n" + e.getMessage();
		}
	}
	
	@Path("export")
	@GET
	@Produces(MediaType.APPLICATION_OCTET_STREAM)
	public Response export() {
		try {
			StringBuilder sb = new StringBuilder();
			for(Field field : SampleDBObj.class.getDeclaredFields()) {
				sb.append(field.getName()).append(",");
			}
			// load everything from database
			List<SampleDBObj> objects = databaseUils.getAll();
			//header
			sb.deleteCharAt(sb.length()-1);
			for (SampleDBObj obj : objects) {
				sb.append("\r\n");
				sb.append(obj.toCSVLine());
			}
			return Response.ok(sb.toString()).header("Content-Disposition", "attachment; filename=" + new Date().toString() + "-export-objs.csv").build();
			
		} catch (SQLException e) {
			e.printStackTrace();
			return null;
		}		
	}
}
```
Info: if you get know the Error ``Caused by: com.mysql.cj.exceptions.InvalidConnectionAttributeException: The server time zone value`` pls just run this Query on your Database: ``SET GLOBAL time_zone = "+3:00";`` 
What is new now is the return type ``Response``. With this we can for example set the Response Code to the "[HTTP Code](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes) 200" - which means the request ran as intended or set any other HTTP Code for our response. 
With Gson from Google we can convert our objects directly into a JSON without having to worry about parsing some objects.
Anything else that happens now should be known by now. For some methods we pass our query parameters, check if they are valid, if so the object is created and added to the database or the object with the name XYZ is loaded from the database.

We' re done here.
We now have a running versioned microservice that queries a database and sends the result as JSON to the client.

### Next Step:   [Dockerizing our Service](https://whit-e.com/articles/dockerizing-our-service)

***Info**/ **best practice**: Why should I always check the database for each request? Just create a **cache**. When the server starts or adds data to the database, it is filled with data. Advantage: significantly less load on the system and your database*

#### Project: [GitHub: microservice_blueprint_java](https://github.com/whit-e/microservice_blueprint_java)
