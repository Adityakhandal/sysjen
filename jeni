node{
stage('SCM Checkout'){
git ''
}
stage('Compile-Package'){
defmvnHome =  tool name: 'Mavan3', type: 'maven'
sh "${mvnHome}/bin/mvn package"
}
stage('Email Notification'){
mail bcc: '', body: '''Build successful!!!!
Thanks,
Mahesh''', cc: '', from: '', replyTo: '', subject: 'Build successfull', to: 'smahesh2305@gmail.com'
}
}
