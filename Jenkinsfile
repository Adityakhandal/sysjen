node {
	//todo - Store port to Device type in map, after all bugs are fixed. 
	def listenerPorts=[];
	def remoteHost
		def remoteUser
		def baseDir
		def protocol 
		def branch
		stage ('Parse Params'){
			echo this.params.toString()
				if(this.params.server_port !=null)
				{
					print this.params.server_port
						String[]  rawPorts=this.params.server_port.split(',')
						for (port in rawPorts)
						{
							if( port.trim().isInteger())
							{
								listenerPorts.add(Integer.valueOf(port.trim()))
							}
							else
							{
								print 'found non-integer '+port.trim()+' in ports'
									error ('found non-integer '+port.trim()+' in server_port' + 'aborting the build')
							}
						}
					println listenerPorts

				}
				else
				{
					error ('server_port has not been specified')
				}
			if (this.params.server_hostname!=null)
			{
				remoteHost=this.params.server_hostname
			}
			else
			{
				error ('server_hostname is null')
			}

			if (this.params.remote_user!=null)
			{
				remoteUser=this.params.remote_user
			}
			else
			{
				error ('remoteUser is null')
			}


			if (this.params.base_dir!=null)
			{
				baseDir=this.params.base_dir
			}
			else
			{
				error ('base_dir is null')
			}

			if (this.params.protocol!=null)
			{
				protocol=this.params.protocol
			}
			else
			{
				protocol='gt'
			}
			if (this.params.branch!=null)
			{
				branch=this.params.branch
			}					
			else
			{
				error ('branch is not specified')	
			}
		}


	stage ('Checkout'){

		checkout([$class: 'GitSCM',
				branches: [[name: branch]],
				userRemoteConfigs: [[credentialsId: 'none',
			       	url: 'git@github.com:Adityakhandal/sysjen.git']]])
	}

	stage ('Build'){
		echo "Building listener..."
			sh "ls -la ${pwd()}"
			sh "ls -la ."
			sh "pwd"
			//buildFolder="${WORKSPACE}@script"
			//	buildfolder="."
			retVal=sh(returnStatus: true,script:"sh ./build.sh")
			echo "Build returned ${retVal.toString()}"
			if (retVal!=0)
			{
				error("Build failed with return value ${retVal.toString()}") 
			}	
		echo "Finished building...."

	}
	stage('SSH transfer and restart') {

		//Later, there will be a single location, with different params.
		//Can use a flag for multiple or single copies. 
		//Do this after bugs fixed. 
		for (port in listenerPorts)
		{

			sshLsCommand="ssh -o StrictHostKeyChecking=no   ${remoteUser}@${remoteHost} ls -l ${baseDir}/${port}"
				echo sshLsCommand


				mkdirCommand="ssh -o StrictHostKeyChecking=no   ${remoteUser}@${remoteHost} mkdir -p ${baseDir}/${port}"
				echo mkdirCommand

				scpCopyCommand="scp -o StrictHostKeyChecking=no  -r build/libs ${remoteUser}@${remoteHost}:${baseDir}/${port}"
				echo scpCopyCommand

				rsyncCommand="rsync -e \'ssh -o StrictHostKeyChecking=no\' --recursive --times --compress --delete --progress build/libs/ ${remoteUser}@${remoteHost}:${baseDir}/${port}"
				echo rsyncCommand


				//protocol = 'gt'
				serverPort=port + 6000

				sshRestartCommand="ssh -o StrictHostKeyChecking=no   ${remoteUser}@${remoteHost} sh ${baseDir}/${port}/production_restart.sh ${port} ${serverPort} ${protocol}"
				echo sshRestartCommand

				try{
					sshagent(credentials : ['none']) {	
						//todo add checks for return values here
						//make directory if it doesnt exist
						sh mkdirCommand
							//This is a test command
							sh sshLsCommand
							//This is the actual copy command
							sh rsyncCommand
							//This command starts the server. 
							sh sshRestartCommand
					}
				}
				catch(err)
				{
					echo "This is a false alarm, because we're waiting 30 secs to see the logs... We're using this workaround until we figure out how to set timeout for "
					echo err.getMessage()
				}
		}
	}
}
