buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.1")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        
        // Mapbox Maps SDK repository
        maven {
            url = uri("https://api.mapbox.com/downloads/v2/releases/maven")
            authentication {
                create<BasicAuthentication>("basic")
            }
            credentials {
                username = "mapbox"
                // Load the Mapbox token securely, prioritizing different sources
                // 1. First try from local.properties (gitignored file)
                // 2. Then from system environment variables
                // 3. Finally from gradle.properties (with placeholder value)
                val localPropertiesFile = rootProject.file("local.properties")
                val mapboxToken = if (localPropertiesFile.exists()) {
                    val localProperties = java.util.Properties()
                    localProperties.load(java.io.FileInputStream(localPropertiesFile))
                    localProperties.getProperty("MAPBOX_DOWNLOADS_TOKEN") ?: ""
                } else {
                    ""
                }
                
                password = when {
                    mapboxToken.isNotEmpty() && mapboxToken != "PLACE_YOUR_TOKEN_IN_LOCAL_PROPERTIES_FILE" -> mapboxToken
                    System.getenv("MAPBOX_DOWNLOADS_TOKEN") != null -> System.getenv("MAPBOX_DOWNLOADS_TOKEN")
                    project.hasProperty("MAPBOX_DOWNLOADS_TOKEN") -> project.property("MAPBOX_DOWNLOADS_TOKEN") as String
                    else -> {
                        logger.warn("WARNING: MAPBOX_DOWNLOADS_TOKEN not found. Mapbox SDK may not be available.")
                        ""
                    }
                }
            }
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
