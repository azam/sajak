dependencies {
  annotationProcessor(libs.lombok)

  compileOnly(libs.lombok)

  implementation(project(":koopa"))
  implementation(libs.jakarta.annotation.api)
  implementation(libs.proleap.cobol.parser)
  implementation(libs.javapoet)
  implementation(libs.slf4j.api)
  implementation(libs.logback.classic)

  testAnnotationProcessor(libs.lombok)

  testCompileOnly(libs.lombok)

  testImplementation(platform(libs.junit.bom))
  testImplementation(libs.junit.jupiter)
  testImplementation(libs.junit.pioneer)
}
