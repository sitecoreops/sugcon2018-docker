package Sugcon2018Docker.buildTypes

import Sugcon2018Docker.buildTypes.Sugcon2018Docker_Build
import jetbrains.buildServer.configs.kotlin.v2017_2.*
import jetbrains.buildServer.configs.kotlin.v2017_2.buildSteps.script
import jetbrains.buildServer.configs.kotlin.v2017_2.failureConditions.BuildFailureOnText
import jetbrains.buildServer.configs.kotlin.v2017_2.failureConditions.failOnText
import jetbrains.buildServer.configs.kotlin.v2017_2.triggers.finishBuildTrigger

object Sugcon2018Docker_Deploy : BuildType({
    uuid = "f1b9b6d6-195d-4508-81c2-d4029458a68c"
    id = "Sugcon2018Docker_Deploy"
    name = "Deploy"

    enablePersonalBuilds = false
    type = BuildTypeSettings.Type.DEPLOYMENT
    buildNumberPattern = "%dep.Sugcon2018Docker_Build.build.number%"
    maxRunningBuilds = 1

    steps {
        script {
            name = "Deploy stacks"
            scriptContent = """
                set -a
                SERVICE_CM_IMAGE_DIGEST=%dep.Sugcon2018Docker_Build.env.SERVICE_CM_IMAGE_DIGEST%
                SERVICE_CD_IMAGE_DIGEST=%dep.Sugcon2018Docker_Build.env.SERVICE_CD_IMAGE_DIGEST%
                
                docker stack deploy --prune --compose-file ./docker-compose.web.yml %dep.Sugcon2018Docker_Build.teamcity.build.branch%-web
                docker stack deploy --prune --compose-file ./docker-compose.proxy.yml proxy
            """.trimIndent()
        }
    }

    triggers {
        finishBuildTrigger {
            buildTypeExtId = Sugcon2018Docker_Build.id
            successfulOnly = true
            branchFilter = "+:*"
        }
    }

    failureConditions {
        failOnText {
            conditionType = BuildFailureOnText.ConditionType.CONTAINS
            pattern = "failed to update service"
            failureMessage = "Failed to update service"
            reverse = false
            stopBuildOnFailure = true
        }
        failOnText {
            conditionType = BuildFailureOnText.ConditionType.CONTAINS
            pattern = "yaml: line"
            failureMessage = "YAML parsing error"
            reverse = false
            stopBuildOnFailure = true
        }
        failOnText {
            conditionType = BuildFailureOnText.ConditionType.CONTAINS
            pattern = "failed to create service"
            failureMessage = "Failed to create service"
            reverse = false
            stopBuildOnFailure = true
        }
    }

    dependencies {
        dependency(Sugcon2018Docker.buildTypes.Sugcon2018Docker_Build) {
            snapshot {
                onDependencyFailure = FailureAction.FAIL_TO_START
            }

            artifacts {
                artifactRules = "*.yml"
            }
        }
    }

    requirements {
        equals("env.AGENT_NAME", "deploy-agent")
    }
})
