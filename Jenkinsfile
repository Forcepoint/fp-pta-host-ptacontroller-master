pipeline {
    agent {
        label 'pta-controller'
    }
    triggers {
        cron('H 19 * * 6')
    }
    options {
        disableConcurrentBuilds()
        buildDiscarder logRotator(numToKeepStr: '10')
    }
    stages {
        stage('Roles') {
            steps {
                sh '''
                    virtualenv virt_ansible
                    source virt_ansible/bin/activate
                    pip install -r requirements.txt
                    ansible-galaxy install --role-file=requirements.yml --force --roles-path=./roles
                    deactivate
                   '''
            }
        }
        stage('Mount') {
            steps {
                sh '''
                    source virt_ansible/bin/activate
                    ansible-playbook -i hosts mount.yml
                    deactivate
                   '''
            }
        }
        stage('Playbook') {
            steps {
                sh '''
                    source virt_ansible/bin/activate
                    ansible-playbook -i hosts --vault-password-file /mnt/extra/service/vault_password.txt main.yml
                    deactivate
                   '''
            }
        }
     }
    post {
        failure {
            emailext body: '''$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS<br><br>Check the console output at ${BUILD_URL}console to view the results.''', mimeType: 'text/html', recipientProviders: [requestor()], subject: '$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!', to: "pta-admin@company.com"
        }
    }
}