project_name = "st"
aws_region = "us-west-2"
env_type = "dev"
db_engine = "postgres"
db_engine_version = "12.4"
image = "docker.io/denisenkoai/test:latest"
env = {
  SPRING_PROFILES_ACTIVE = "aws"
}
deploy_type = "k8s"