import com.diffplug.gradle.spotless.SpotlessExtension
import org.apache.tools.ant.taskdefs.Java

dependencies {
  implementation(libs.koopa.dep.jaxen)
  implementation(libs.koopa.dep.log4j)
  implementation(libs.koopa.dep.opencsv)
  implementation(libs.koopa.dep.swingx)
  testImplementation(libs.koopa.dep.junit)
  // testRuntimeOnly(libs.junit.platform.launcher)
  testRuntimeOnly(libs.junit.vintage.engine)
}

sourceSets {
  main {
    java {
      setSrcDirs(
        listOf(
          files("koopa/src/core"),
          files("koopa/src/templates"),
          files("koopa/src/dsl") { exclude("koopa/dsl/stage/runtime/**") },
          files("koopa/src/cics"),
          files("koopa/src/sql"),
          files("koopa/src/cobol"),
        ),
      )
    }
  }
  test {
    java {
      setSrcDirs(
        listOf(
          files("koopa/src/dsl") {
            include("koopa/dsl/stage/runtime/**")
            exclude("koopa/**")
          },
          files("koopa/test/cics") {
            include("**/*.java")
          },
          files("koopa/test/cobol") {
            include("**/*.java")
          },
          files("koopa/test/core") {
            include("**/*.java")
          },
          files("koopa/test/dsl") {
            include("**/*.java")
          },
          files("koopa/test/sql") {
            include("**/*.java")
          },
        ),
      )
    }
  }
}

java {
  toolchain {
    languageVersion.set(JavaLanguageVersion.of(17))
    vendor.set(JvmVendorSpec.ORACLE)
  }
  sourceCompatibility = JavaVersion.VERSION_1_8
  targetCompatibility = JavaVersion.VERSION_1_8
}

testing {
  suites {
    @Suppress("UnstableApiUsage")
    getByName<JvmTestSuite>("test") {
      useJUnit(libs.koopa.dep.junit.get().version)
//      sources {
//        java {
//          srcDirs(
//            files("koopa/src/dsl") {
//              exclude("koopa/**")
//              include("koopa/dsl/stage/runtime/**")
//            },
//            files("koopa/test/core"),
//            files("koopa/test/templates"),
//            files("koopa/test/dsl"),
//            files("koopa/test/cics"),
//            files("koopa/test/sql"),
//            files("koopa/test/cobol"),
//          )
//        }
//      }
    }
  }
}

configure<SpotlessExtension> { java { targetExclude("koopa/**") } }

tasks.withType<JavaCompile>().configureEach {
  println(this)
  val testSrcDirs = sourceSets.test.get().allJava.srcDirs.forEach { println(it) }
  options.encoding = "UTF-8"
}

tasks.named<Test>("test") {
  useJUnitPlatform {
    includeEngines("junit-vintage")
    excludeEngines("junit-jupiter")
  }
  // val testSrcDirs = sourceSets.test.get().allJava.srcDirs.forEach { println(it) }
}
