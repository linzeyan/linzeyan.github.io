---
title: "Some Jenkinsfile examples"
date: 2019-11-06T17:29:46+08:00
menu:
  sidebar:
    name: "Some Jenkinsfile examples"
    identifier: jenkins-jenkinsfile-examples
    weight: 10
tags: ["URL", "Jenkins"]
categories: ["URL", "Jenkins"]
---

- [Some Jenkinsfile examples](https://gist.github.com/merikan/228cdb1893fca91f0663bab7b095757c)

##### Parallel

```
#!/usr/bin/env groovy
pipeline {
  agent any

  stages {
    stage("Build") {
      steps {
        sh 'mvn -v'
      }
    }

    stage("Testing") {
      parallel {
        stage("Unit Tests") {
          agent { docker 'openjdk:7-jdk-alpine' }
          steps {
            sh 'java -version'
          }
        }
        stage("Functional Tests") {
          agent { docker 'openjdk:8-jdk-alpine' }
          steps {
            sh 'java -version'
          }
        }
        stage("Integration Tests") {
          steps {
            sh 'java -version'
          }
        }
      }
    }

    stage("Deploy") {
      steps {
        echo "Deploy!"
      }
    }
  }
}
```

##### When

```
#!/usr/bin/env groovy
pipeline {
   agent any

   environment {
      VALUE_ONE = '1'
      VALUE_TWO = '2'
      VALUE_THREE = '3'
   }

   stages {

      // skip a stage while creating the pipeline
      stage("A stage to be skipped") {
         when {
            expression { false }  //skip this stage
         }
         steps {
            echo 'This step will never be run'
         }
      }

      // Execute when branch = 'master'
      stage("BASIC WHEN - Branch") {
         when {
            branch 'master'
	 }
         steps {
            echo 'BASIC WHEN - Master Branch!'
         }
      }

      // Expression based when example with AND
      stage('WHEN EXPRESSION with AND') {
         when {
            expression {
               VALUE_ONE == '1' && VALUE_THREE == '3'
            }
         }
         steps {
            echo 'WHEN with AND expression works!'
         }
      }

      // Expression based when example
      stage('WHEN EXPRESSION with OR') {
         when {
            expression {
               VALUE_ONE == '1' || VALUE_THREE == '2'
            }
         }
         steps {
            echo 'WHEN with OR expression works!'
         }
      }

      // When - AllOf Example
      stage("AllOf") {
        when {
            allOf {
                environment name:'VALUE_ONE', value: '1'
                environment name:'VALUE_TWO', value: '2'
            }
        }
        steps {
            echo "AllOf Works!!"
        }
      }

      // When - Not AnyOf Example
      stage("Not AnyOf") {
         when {
            not {
               anyOf {
                  branch "development"
                  environment name:'VALUE_TWO', value: '4'
               }
            }
         }
         steps {
            echo "Not AnyOf - Works!"
         }
      }
   }
}
```
