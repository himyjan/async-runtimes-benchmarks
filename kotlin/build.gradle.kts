plugins {
    kotlin("jvm") version "2.4.21"
}

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core-jvm:1.10.1")
}

tasks.named<org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile>("compileKotlin") {
    kotlinOptions {
        jvmTarget = "26"
        freeCompilerArgs = listOf("-Xskip-metadata-version-check")
    }
}
