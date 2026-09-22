plugins {
    java
    id("org.springframework.boot") version "4.0.4"
    id("io.spring.dependency-management") version "1.1.7"
}

group = "org.example"
version = "0.0.1-SNAPSHOT"
description = "roomFit"

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}

configurations {
    compileOnly {
        extendsFrom(configurations.annotationProcessor.get())
    }
}

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    compileOnly("org.projectlombok:lombok")
    runtimeOnly("org.postgresql:postgresql")
    implementation("com.pgvector:pgvector:0.1.6")
    implementation("org.hibernate.orm:hibernate-community-dialects:7.2.7.Final")
    annotationProcessor("org.projectlombok:lombok")
    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
    implementation("com.github.gavlyukovskiy:p6spy-spring-boot-starter:1.9.0") // SQL 로그를 보기 위한 의존성
    // 보안 관련 의존성
    implementation("org.springframework.boot:spring-boot-starter-security")
    // JWT Token
    implementation("io.jsonwebtoken:jjwt-api:0.12.6")
    runtimeOnly("io.jsonwebtoken:jjwt-impl:0.12.6")
    runtimeOnly("io.jsonwebtoken:jjwt-jackson:0.12.6")

    implementation("org.springframework.boot:spring-boot-starter-webflux")

    // AWS SDK for Cloudflare R2 (S3 호환)
    implementation("software.amazon.awssdk:s3:2.21.1")

    // JSON library used by GroundedSAMClient
    implementation("org.json:json:20230227")

    // firebase admin sdk
    implementation("com.google.firebase:firebase-admin:9.2.0")
}

tasks.withType<Test> {
    useJUnitPlatform()
}
