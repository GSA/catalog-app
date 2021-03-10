pipeline {
  agent any
  stages {
    stage('workflow:sandbox') {
      when {
        allOf {
          environment name: 'DATAGOV_WORKFLOW', value: 'sandbox'
          anyOf {
            branch 'master'
          }
        }
      }
      environment {
        ANSIBLE_VAULT_FILE = credentials('ansible-vault-secret')
        SSH_KEY_FILE = credentials('datagov-sandbox')
      }
      stages {
        stage('deploy:sandbox') {
          steps {
            ansiColor('xterm') {
              echo 'Deploying with Ansible'
              copyArtifacts projectName: 'deploy-ci-platform-mb/develop', selector: lastSuccessful()
              sh 'mkdir deploy && tar xzf datagov-deploy.tar.gz -C deploy'
              dir('deploy') {
                sh 'bin/jenkins-deploy init'
                sh 'bin/jenkins-deploy deploy sandbox catalog.yml --limit v1'
              }
            }
          }
        }
      }
    }
    stage('workflow:production') {
      when {
        allOf {
          environment name: 'DATAGOV_WORKFLOW', value: 'production'
          anyOf {
            branch 'master'
          }
        }
      }
      environment {
        ANSIBLE_VAULT_FILE = credentials('ansible-vault-secret')
      }
      stages {
        stage('deploy:init') {
          steps {
            ansiColor('xterm') {
              copyArtifacts projectName: 'deploy-ci-platform-mb/master', selector: lastSuccessful()
              sh 'mkdir deploy && tar xzf datagov-deploy.tar.gz -C deploy'
              dir('deploy') {
                sh 'bin/jenkins-deploy init'
              }
            }
          }
        }
        stage('deploy:staging') {
          environment {
            SSH_KEY_FILE = credentials('datagov-prod-ssh')
          }
          steps {
            ansiColor('xterm') {
              dir('deploy') {
                sh 'bin/jenkins-deploy deploy staging catalog.yml --limit v1'
              }
            }
          }
        }
        stage('deploy:production') {
          environment {
            SSH_KEY_FILE = credentials('datagov-prod-ssh')
          }
          steps {
            ansiColor('xterm') {
              dir('deploy') {
                sh 'bin/jenkins-deploy deploy production catalog.yml --limit v1'
              }
            }
          }
        }
      }
    }
  }
  post {
    always {
      step([$class: 'GitHubIssueNotifier', issueAppend: true, issueRepo: 'http://github.com/GSA/datagov-deploy.git'])
      cleanWs()
    }
  }
}
