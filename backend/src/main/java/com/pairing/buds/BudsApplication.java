package com.pairing.buds;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class BudsApplication {

	public static void main(String[] args) {
		SpringApplication.run(BudsApplication.class, args);
	}
}
