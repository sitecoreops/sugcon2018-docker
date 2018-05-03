package Sugcon2018Docker.vcsRoots

import jetbrains.buildServer.configs.kotlin.v2017_2.*
import jetbrains.buildServer.configs.kotlin.v2017_2.vcs.GitVcsRoot

object Sugcon2018Docker_HttpsGithubComSitecoreOpsSugcon2018dockerGit : GitVcsRoot({
    uuid = "c3730286-25ce-4c3c-bb16-61819e3ca5d7"
    id = "Sugcon2018Docker_HttpsGithubComSitecoreOpsSugcon2018dockerGit"
    name = "https://github.com/sitecoreops/sugcon2018-docker.git"
    pollInterval = 10
    url = "https://github.com/sitecoreops/sugcon2018-docker.git"
    branch = "master"
    branchSpec = "+:refs/heads/*"
    checkoutSubmodules = GitVcsRoot.CheckoutSubmodules.IGNORE
    useMirrors = false
    authMethod = password {
        userName = "pbering"
        password = "credentialsJSON:ab02310e-2f7d-4c17-b459-b5af9193bfb1"
    }
})
