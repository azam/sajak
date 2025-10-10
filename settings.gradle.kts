pluginManagement {
  repositories {
    gradlePluginPortal()
    mavenCentral()
    google()
    maven { url = uri("https://maven.scijava.org/content/repositories/public/") }
    mavenLocal()
  }
}

plugins { id("org.gradle.toolchains.foojay-resolver").version("1.0.0") }

@Suppress("UnstableApiUsage")
toolchainManagement {
  jvm {
    javaRepositories {
      repository("foojay") {
        resolverClass.set(org.gradle.toolchains.foojay.FoojayToolchainResolver::class.java)
      }
    }
  }
}

@Suppress("UnstableApiUsage")
dependencyResolutionManagement {
  repositories {
    gradlePluginPortal()
    mavenCentral()
    google()
    maven { url = uri("https://maven.scijava.org/content/repositories/public/") }
    mavenLocal()
  }
}

rootProject.name = "sajak"

include("koopa", "core", "pantun")
