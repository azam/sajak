dependencies {
  annotationProcessor(libs.lombok)

  compileOnly(libs.lombok)

  implementation(project(":core"))
  implementation(libs.jakarta.annotation.api)
  implementation(libs.javapoet)
  implementation(libs.slf4j.api)
  implementation(libs.logback.classic)

  testAnnotationProcessor(libs.lombok)

  testCompileOnly(libs.lombok)

  testImplementation(platform(libs.junit.bom))
  testImplementation(libs.junit.jupiter)
  testImplementation(libs.junit.pioneer)
}
