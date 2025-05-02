@Library ("SharedLib@master")_

pipeline
{
	agent any

	parameters {
		string(name: 'STACKS', defaultValue: 'Mothership 2,Caseys', description: 'Comma-separated list of stacks to execute')
	}

	environment 
	{
		EXECUTION_LIMIT = 5
		S3_BUCKET = 'script-execution-log'
	}

	stages 
	{
		stage('Prepare Death Ray')
		{
			steps
			{
				sh 'echo Death Ray coming online...'
			}
			post {
				always {
					script {
						sh "echo stage complete."
					}
				}
			}
		}
		stage('Make A Nice Tuna Salad')
		{
			steps 
			{
			    script
			    {
			        echo "Fuck off, world!"
			    }
				script 
				{
					def stackToNamespace = [
						"Caseys": 'caseys',
						"Dairy Queen": 'dairyqueen',
						"Mothership" : 'mothership',
						"Mothership 2" : 'mothership2',
						"Papa Johns": 'papajohns',
						"Pizza Hut US" : 'pizzahut',
						"Pizza Hut ME" : 'pizzahutme',
						"Punchh Yum UK": 'punchhyumuk',
						"Taco Bell": 'tacobell',
						"Australia": "australia",
						"Pre-Prod" : 'pre-prod',
						"QA" : 'qa',
						"Sandbox": 'service'
					]
					def stacks = params.STACKS.split(',').collect { it.trim() }

					stacks.each
					{ stack ->
						script
						{
							sh "echo stack = ${stack}"
							def trimmedStack = stack.trim()
							sh "echo trimmedStack=${trimmedStack}"
							def safeStackName = trimmedStack.replaceAll(' ', '_')
							sh "echo safeStackName=${safeStackName}"
							def namespace = stackToNamespace[trimmedStack]
							sh "echo namespace = ${namespace}"
							def today = new Date().format('yyyy-MM-dd')
							sh "echo today = ${today}"

							if (namespace)
							{
								sh "echo namespace=${namespace}"
							}
							else
							{
								error "Unknown stack: '${trimmedStack}'. Please update the mapping."
							}
						}
					}
				}
			}
		}
		stage('Reticulating splines...')
		{
			steps
			{
				script
				{
					sh 'echo Reticulating splines...'
					sh '''
						PULL_REQUEST='
blah blah
yecch

zoopie!
'
						echo "${PULL_REQUEST}"
					'''

					sh 'echo Mandelbot linguists hidden successfully'
				}
			}
		}
		stage('Report to the Main Battle Fleet')
		{
			steps
			{
				sh '''
set +x
echo "Testing..."
temp_variable='blah\nyecch\neeeuuuwwww'
echo $temp_variable;

echo "Testing...."
echo "1, 2, 3."
'''
			}
		}
		stage('Destroy all hoo-mans')
		{
			steps
			{
				sh 'set +x'
				sh 'echo "Destroying all hoo-mans..."'
			}
		}
	}
}
