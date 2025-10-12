package edu.sm;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class UsertestApplication {

    public static void main(String[] args) {
        SpringApplication.run(UsertestApplication.class, args);
    }

}
