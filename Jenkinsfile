def notify(status){
	emailext (
		body: '$DEFAULT_CONTENT',
		recipientProviders: [
			[$class: 'CulpritsRecipientProvider'],
			[$class: 'DevelopersRecipientProvider'],
			[$class: 'RequesterRecipientProvider']
		],
		replyTo: '$DEFAULT_REPLYTO',
		subject: '$DEFAULT_SUBJECT',
		to: '$DEFAULT_RECIPIENTS'
	)
}

@NonCPS
def killall_jobs() {
	def jobname = env.JOB_NAME
	def buildnum = env.BUILD_NUMBER.toInteger()
	def killnums = ""
	def job = Jenkins.instance.getItemByFullName(jobname)
	def fixed_job_name = env.JOB_NAME.replace('%2F','/')

	for (build in job.builds) {
		if (!build.isBuilding()) { continue; }
		if (buildnum == build.getNumber().toInteger()) { continue; println "equals" }
		if (buildnum < build.getNumber().toInteger()) { continue; println "newer" }

		echo "Kill task = ${build}"

		killnums += "#" + build.getNumber().toInteger() + ", "

		build.doStop();
	}

	if (killnums != "") {
		slackSend color: "danger", channel: "#jenkins", message: "Killing task(s) ${fixed_job_name} ${killnums} in favor of #${buildnum}, ignore following failed builds for ${killnums}"
	}
	echo "Done killing"
}

def buildStep(DOCKER_ROOT, DOCKERIMAGE, DOCKERTAG, DOCKERFILE, BUILD_NEXT) {
	def fixed_job_name = env.JOB_NAME.replace('%2F','/')
	try {
		checkout scm;

		def buildenv = '';
		def tag = '';
		if (env.BRANCH_NAME.equals('master')) {
			buildenv = 'production';
			tag = "${DOCKERTAG}";
		} else if (env.BRANCH_NAME.equals('dev')) {
			buildenv = 'development';
			tag = "${DOCKERTAG}-dev";
		} else {
			throw new Exception("Invalid branch, stopping build!");
		}

		docker.withRegistry("https://index.docker.io/v1/", "dockerhub") {
			def customImage
			stage("Building ${DOCKERIMAGE}:${tag}...") {
				customImage = docker.build("${DOCKER_ROOT}/${DOCKERIMAGE}:${tag}", "--build-arg BUILDENV=${buildenv} --network=host --pull -f ${DOCKERFILE} .");
			}

			stage("Pushing to docker hub registry...") {
				customImage.push();
			}
		}
	} catch(err) {
		slackSend color: "danger", channel: "#jenkins", message: "Build Failed: ${fixed_job_name} #${env.BUILD_NUMBER} Target: ${DOCKER_ROOT}/${DOCKERIMAGE}:${tag} (<${env.BUILD_URL}|Open>)"
		currentBuild.result = 'FAILURE'
		notify("Build Failed: ${fixed_job_name} #${env.BUILD_NUMBER} Target: ${DOCKER_ROOT}/${DOCKERIMAGE}:${tag}")
		throw err
	}
}

def buildManifest(DOCKER_ROOT, DOCKERIMAGE, DOCKERTAG, DOCKERFILE, PLATFORMS, BUILD_NEXT) {
	def fixed_job_name = env.JOB_NAME.replace('%2F','/')
	try {
		checkout scm;

		def buildenv = '';
		def tag = '';
		if (env.BRANCH_NAME.equals('master')) {
			buildenv = 'production';
			tag = "${DOCKERTAG}";
		} else if (env.BRANCH_NAME.equals('dev')) {
			buildenv = 'development';
			tag = "${DOCKERTAG}-dev";
		} else {
			throw new Exception("Invalid branch, stopping build!");
		}

		docker.withRegistry("https://index.docker.io/v1/", "dockerhub") {
			stage("Building ${DOCKERIMAGE}:${tag} manifest...") {
				sh('docker version');
				def platformsString = "";
				PLATFORMS.each { p ->
					sh("docker pull ${DOCKER_ROOT}/${DOCKERIMAGE}:${tag}_${p}");
					platformsString = "${platformsString} ${DOCKER_ROOT}/${DOCKERIMAGE}:${tag}_${p}"
				}
				
				sh("docker manifest create ${DOCKER_ROOT}/${DOCKERIMAGE}:${tag} ${platformsString}");
				sh("docker manifest push ${DOCKER_ROOT}/${DOCKERIMAGE}:${tag}");
			}
		}

		def branches = [:]

		BUILD_NEXT.each { v ->
			branches["Build ${v}"] = { 
				build "${v}/${env.BRANCH_NAME}";
			}
		}

		//parallel branches; // DISABLE FOR NOW
	} catch(err) {
		slackSend color: "danger", channel: "#jenkins", message: "Build Failed: ${fixed_job_name} #${env.BUILD_NUMBER} Target: ${DOCKER_ROOT}/${DOCKERIMAGE}:${tag} (<${env.BUILD_URL}|Open>)"
		currentBuild.result = 'FAILURE'
		notify("Build Failed: ${fixed_job_name} #${env.BUILD_NUMBER} Target: ${DOCKER_ROOT}/${DOCKERIMAGE}:${tag}")
		throw err
	}
}

node('master') {
	killall_jobs();
	def fixed_job_name = env.JOB_NAME.replace('%2F','/');
	slackSend color: "good", channel: "#jenkins", message: "Build Started: ${fixed_job_name} #${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)";
	
	checkout scm;

	def branches = [:];
	def project = readJSON file: "JenkinsEnv.json";

	project.builds.each { v ->
		branches["Build ${v.DockerRoot}/${v.DockerImage}:${v.DockerTag}"] = {
			def platforms = [:];

			v.Platforms.each { p -> 
				platforms["Build ${v.DockerRoot}/${v.DockerImage}:${v.DockerTag}_${p}"] = {
					stage("Build ${p} version") {
						node(p) {
							buildStep(v.DockerRoot, v.DockerImage, "${v.DockerTag}_${p}", v.Dockerfile, [])
						}
					}
				}
			};

			parallel platforms;

			stage('Build multi-arch manifest') {
				node() {
					buildManifest(v.DockerRoot, v.DockerImage, v.DockerTag, v.Dockerfile, v.Platforms, v.BuildIfSuccessful)
				}
			}
		}
	}
	
	sh "rm -rf ./*"

	parallel branches;
}