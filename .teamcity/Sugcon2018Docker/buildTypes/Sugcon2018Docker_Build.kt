package Sugcon2018Docker.buildTypes

import jetbrains.buildServer.configs.kotlin.v2017_2.*
import jetbrains.buildServer.configs.kotlin.v2017_2.buildFeatures.dockerSupport
import jetbrains.buildServer.configs.kotlin.v2017_2.buildSteps.powerShell
import jetbrains.buildServer.configs.kotlin.v2017_2.triggers.vcs

object Sugcon2018Docker_Build : BuildType({
    uuid = "0d522cf1-d709-447f-b660-182873b52de3"
    id = "Sugcon2018Docker_Build"
    name = "Build"

    artifactRules = "docker-compose.*.yml"
    buildNumberPattern = "1.0.%build.counter%-%teamcity.build.branch%"
    maxRunningBuilds = 1

    params {
        param("env.SERVICE_CD_IMAGE_DIGEST", "")
        param("env.SERVICE_CM_IMAGE_DIGEST", "")
    }

    vcs {
        root(Sugcon2018Docker.vcsRoots.Sugcon2018Docker_HttpsGithubComSitecoreOpsSugcon2018dockerGit)
    }

    steps {
        powerShell {
            name = "Build"
            scriptMode = file {
                path = "Build.ps1"
            }
            param("jetbrains_powershell_scriptArguments", "-Version %build.number% -Push")
        }
    }

    triggers {
        vcs {
            triggerRules = """
                -:README.md
                -:.teamcity/**
                -:presentation/**
                -:other/**
                -:images/**
                -:infrastructure/**
            """.trimIndent()
            branchFilter = ""
        }
    }

    features {
        dockerSupport {
            cleanupPushedImages = true
        }
        feature {
            type = "perfmon"
        }
    }
})
