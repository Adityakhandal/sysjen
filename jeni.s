node{
stage('SCM Checkout'){
git 'https://github.com/Adityakhandal/sysjen.git'
}
stage('Compile-Package'){
defmvnHome =  tool name: 'Mavan3', type: 'maven'
sh "${mvnHome}/bin/mvn package"
}
stage('Email Notification'){
mail bcc: '', body: '''Build successful!!!!
Thanks,
aditya''', cc: '', from: '', replyTo: '', subject: 'Build successfull', to: 'adityakhandal.axestrack@gmail.com'
}
}
