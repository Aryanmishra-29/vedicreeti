allprojects {
    repositories {
        google()
        mavenCentral()
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

subprojects {
    pluginManager.withPlugin("com.android.library") {
        val androidExt = project.extensions.findByName("android")
        if (androidExt != null) {
            try {
                val getNamespace = androidExt.javaClass.getMethod("getNamespace")
                val namespace = getNamespace.invoke(androidExt) as? String
                if (namespace.isNullOrEmpty()) {
                    val groupName = project.group.toString()
                    val setNamespace = androidExt.javaClass.getMethod("setNamespace", String::class.java)
                    setNamespace.invoke(androidExt, if (groupName.isNotEmpty()) groupName else "com.example.dynamic")
                }
            } catch (e: Exception) {
                // Ignore if method not found or other errors
            }
        }
    }
}