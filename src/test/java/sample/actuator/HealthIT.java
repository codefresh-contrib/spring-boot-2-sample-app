package sample.actuator;

import org.junit.Test;

import static io.restassured.RestAssured.given;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.equalTo;

public class HealthIT {
	
	@Test
    public void running() {
		given().when().get("http://localhost:8080/")
            .then().statusCode(200);
    }
	
	@Test
    public void message() {
		given().when().get("http://localhost:8080/")
            .then().body(containsString("Spring boot"));
    }
	
	@Test
    public void fullMessage() {
		given().when().get("http://localhost:8080/")
            .then().body("message",equalTo("Spring boot says hello from a Docker container"));
    }
	
	@Test
    public void health() {
		given().when().get("http://localhost:8080/actuator/health")
            .then().body("status",equalTo("UP"));
    }


}
