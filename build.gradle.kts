import com.diffplug.gradle.spotless.SpotlessExtension
import com.diffplug.spotless.LineEnding
import com.github.benmanes.gradle.versions.updates.DependencyUpdates
import com.github.benmanes.gradle.versions.updates.DependencyUpdatesTask
import io.freefair.gradle.plugins.lombok.LombokExtension
import java.nio.charset.StandardCharsets

plugins {
  idea
  eclipse
  java.apply { false }
  `java-library`.apply { false }
  `jvm-test-suite`.apply { false }
  `test-report-aggregation`.apply { false }
  `jacoco-report-aggregation`.apply { false }
  jacoco.apply { false }
  alias(libs.plugins.lombok).apply { false }
  alias(libs.plugins.gradle.versions).apply { false }
  alias(libs.plugins.spotless).apply { false }
}

repositories {
  gradlePluginPortal()
  mavenCentral()
  google()
  maven { url = uri("https://maven.scijava.org/content/repositories/public/") }
  mavenLocal()
}

interface SequentialService : BuildService<BuildServiceParameters.None>

val sequential = gradle.sharedServices.registerIfAbsent("sequential", SequentialService::class) {
  maxParallelUsages.set(1)
}

configure<LombokExtension> {
  version = rootProject.libs.lombok.asProvider().map { it.version }
}

configure<JacocoPluginExtension> { toolVersion = rootProject.libs.versions.jacoco.get() }

allprojects {
  apply {
    plugin("idea")
    plugin("eclipse")
    plugin(rootProject.libs.plugins.gradle.versions.get().pluginId)
    plugin(rootProject.libs.plugins.spotless.get().pluginId)
  }

  group = "io.azam.sajak"
  version = "0.0.1-SNAPSHOT"

  tasks.withType<DependencyUpdatesTask> {
    checkForGradleUpdate = true
    gradleReleaseChannel = "current"
    outputFormatter = "plain,json,html,xml"
    rejectVersionIf {
      setOf("-beta", "-rc[0-9]", "-alpha", "-m[0-9]").any {
        candidate.version.lowercase().contains(it.toRegex())
      }
    }
  }

  configure<SpotlessExtension> {
    encoding = StandardCharsets.UTF_8
    lineEndings = LineEnding.UNIX
    java {
      googleJavaFormat(rootProject.libs.versions.google.java.format.get()).reorderImports(true)
      removeUnusedImports()
      forbidWildcardImports()
      trimTrailingWhitespace()
      endWithNewline()
    }
    kotlinGradle {
      ktlint(rootProject.libs.versions.ktlint.get()).editorConfigOverride(mapOf("indent_size" to 2))
      trimTrailingWhitespace()
      endWithNewline()
    }
  }
}

subprojects {
  apply {
    plugin("java")
    plugin("java-library")
    plugin("jvm-test-suite")
    plugin("test-report-aggregation")
    plugin(rootProject.libs.plugins.lombok.get().pluginId)
  }

  if (providers.gradleProperty("sajak.jacoco").map { it.toBoolean() }.getOrElse(true)) {
    apply {
      plugin("jacoco")
      plugin("jacoco-report-aggregation")
    }
  }

  configure<JavaPluginExtension> {
    toolchain {
      languageVersion.set(JavaLanguageVersion.of(25))
      vendor.set(JvmVendorSpec.ORACLE)
    }
    sourceCompatibility = JavaVersion.VERSION_25
    targetCompatibility = JavaVersion.VERSION_25
  }

  configure<LombokExtension> {
    version = rootProject.libs.lombok.asProvider().map { it.version }
  }

  testing {
    suites {
      @Suppress("UnstableApiUsage")
      val test by getting(JvmTestSuite::class) {
        useJUnitJupiter(rootProject.libs.versions.junit)
      }
    }
  }

  reporting {
    @Suppress("UnstableApiUsage")
    reports {
    }
  }

  tasks.withType<TestReport> {
    usesService(sequential)
  }

  if (providers.gradleProperty("sajak.jacoco").map { it.toBoolean() }.getOrElse(true)) {
    tasks.withType<JacocoReport> {
      usesService(sequential)
      reports {
        xml.required = true
        csv.required = true
        html.required = true
      }
    }

    tasks.withType<Test> { finalizedBy(tasks.jacocoTestReport) }
  }
}
