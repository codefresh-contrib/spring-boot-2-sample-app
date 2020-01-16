package sample.actuator;

import org.junit.Test;
import org.junit.BeforeClass;

import static io.restassured.RestAssured.given;
import io.restassured.RestAssured;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.equalTo;

public class HealthIT {

  @BeforeClass
  public static void setup() {
      String port = System.getProperty("server.port");
      if (port == null) {
          RestAssured.port = Integer.valueOf(8080);
      }
      else{
          RestAssured.port = Integer.valueOf(port);
      }

      String baseHost = System.getProperty("server.host");
      if(baseHost==null){
          baseHost = "http://localhost";
      }
      RestAssured.baseURI = baseHost;

  }
	
	@Test
    public void running() {
		given().when().get("/")
            .then().statusCode(200);
    }
	
	@Test
    public void message() {
		given().when().get("/")
            .then().body(containsString("Spring boot"));
    }
	
	@Test
    public void fullMessage() {
		given().when().get("/")
            .then().body("message",equalTo("Spring boot says hello from a Docker container"));
    }
	
	@Test
    public void health() {
		given().when().get("/actuator/health")
            .then().body("status",equalTo("UP"));
    }


}
