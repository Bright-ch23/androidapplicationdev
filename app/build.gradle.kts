plugins {
    id("org.jetbrains.compose")
    id("org.jetbrains.kotlin.jvm")
}

dependencies {
    implementation(compose.desktop.currentOs)
    implementation("org.apache.poi:poi-ooxml:5.2.3")
}

compose.desktop {
    application {
        mainClass = "com.example.grade_calculator.MainActivityKt"
        nativeDistributions {
            targetFormats(org.jetbrains.compose.desktop.application.dsl.TargetFormat.Dmg, org.jetbrains.compose.desktop.application.dsl.TargetFormat.Msi, org.jetbrains.compose.desktop.application.dsl.TargetFormat.Deb)
            packageVersion = "1.0.0"
        }
    }
}
