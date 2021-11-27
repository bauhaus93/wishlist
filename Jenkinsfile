pipeline {
    agent any
    stages {
        stage ("Clone repository") {
            checkout scm
        }

        stage("Build base image") {
			dir ("backend") {
				sh cp "../docker/backend/Dockerfile-base" "./Dockerfile"
				docker.build("schlemihl/wishlist-backend-base")
			}
        }

		stage("Build image") {
			dir ("backend") {
				sh cp "../docker/backend/Dockerfile" "./Dockerfile"
				def backend_img = docker.build("schlemihl/wishlist-backend")
			}
        }

    }
}
