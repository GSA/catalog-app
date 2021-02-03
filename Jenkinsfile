pipeline {
  agent any
  environment {
    PLAYBOOK = 'catalog.yml'
  }
  stages {
    stage('workflow:sandbox') {
      when { anyOf { environment name: 'DATAGOV_WORKFLOW', value: 'sandbox' } }
      environment {
        ANSIBLE_VAULT_FILE = credentials('ansible-vault-secret')
        SSH_KEY_FILE = credentials('datagov-sandbox')
      }
      stages {
        stage('deploy:sandbox') {
          when { anyOf { branch 'adborden/ci-test' } }
          steps {
            ansiColor('xterm') {
              echo 'Deploying with Ansible'
              copyArtifacts parameters: "branch_name=bugfix/jenkins-branch", projectName: 'adborden-deploy-ci-platform', selector: lastSuccessful(), target: 'deploy'
              dir('deploy') {
                sh 'bin/jenkins-deploy deploy sandbox catalog.yml --limit v1'
              }
            }
          }
        }
      }
    }
    stage('workflow:production') {
      when { anyOf { environment name: 'DATAGOV_WORKFLOW', value: 'production' } }
      environment {
        ANSIBLE_VAULT_FILE = credentials('ansible-vault-secret')
        SSH_KEY_FILE = credentials('datagov-sandbox')
      }
      stages {
        stage('deploy') {
          when { anyOf { branch 'master' } }
          steps {
            ansiColor('xterm') {
              echo 'Deploying with Ansible'
              copyArtifacts parameters: 'branch_name=master', projectName: 'adborden-deploy-ci-platform', selector: lastSuccessful(), target: 'deploy'
              dir('deploy') {
                sh 'bin/jenkins-deploy deploy staging catalog.yml --limit v1'
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
      step([$class: 'GitHubIssueNotifier', issueAppend: true])
    }
  }
}
