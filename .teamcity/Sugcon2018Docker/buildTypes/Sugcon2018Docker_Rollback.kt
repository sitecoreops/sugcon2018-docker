package Sugcon2018Docker.buildTypes

import jetbrains.buildServer.configs.kotlin.v2017_2.*
import jetbrains.buildServer.configs.kotlin.v2017_2.buildSteps.script

object Sugcon2018Docker_Rollback : BuildType({
    uuid = "73818438-937d-401f-adbf-8a76d70db249"
    id = "Sugcon2018Docker_Rollback"
    name = "Rollback (using --rollback)"

    enablePersonalBuilds = false
    type = BuildTypeSettings.Type.DEPLOYMENT
    maxRunningBuilds = 1

    vcs {
        showDependenciesChanges = true
    }

    steps {
        script {
            name = "Rollback stacks"
            scriptContent = """
                docker service update --rollback web_cm
                docker service update --rollback web_cd
                docker service update --rollback proxy_nginx
            """.trimIndent()
        }
    }

    requirements {
        equals("env.AGENT_NAME", "deploy-agent")
    }
})
