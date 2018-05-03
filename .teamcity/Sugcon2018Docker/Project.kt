package Sugcon2018Docker

import Sugcon2018Docker.buildTypes.*
import Sugcon2018Docker.vcsRoots.*
import Sugcon2018Docker.vcsRoots.Sugcon2018Docker_HttpsGithubComSitecoreOpsSugcon2018dockerGit
import jetbrains.buildServer.configs.kotlin.v2017_2.*
import jetbrains.buildServer.configs.kotlin.v2017_2.Project
import jetbrains.buildServer.configs.kotlin.v2017_2.projectFeatures.VersionedSettings
import jetbrains.buildServer.configs.kotlin.v2017_2.projectFeatures.versionedSettings

object Project : Project({
    uuid = "6a81a61b-6475-47b5-a980-8575ae62d924"
    id = "Sugcon2018Docker"
    parentId = "_Root"
    name = "Sugcon 2018 Docker"
    description = "Painless deployments of Sitecore using Docker Swarm"

    vcsRoot(Sugcon2018Docker_HttpsGithubComSitecoreOpsSugcon2018dockerGit)

    buildType(Sugcon2018Docker_Rollback)
    buildType(Sugcon2018Docker_Deploy)
    buildType(Sugcon2018Docker_Build)

    features {
        versionedSettings {
            id = "PROJECT_EXT_2"
            mode = VersionedSettings.Mode.ENABLED
            buildSettingsMode = VersionedSettings.BuildSettingsMode.PREFER_SETTINGS_FROM_VCS
            rootExtId = Sugcon2018Docker_HttpsGithubComSitecoreOpsSugcon2018dockerGit.id
            showChanges = false
            settingsFormat = VersionedSettings.Format.KOTLIN
            storeSecureParamsOutsideOfVcs = true
        }
    }
})
