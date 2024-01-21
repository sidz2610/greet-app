# Greet Application Deployment

## Dependencies
- Python 3.6
- Redis server

## Local Testing
1. Install dependencies: `pip3 install flask redis`
2. Start Redis server: `redis-server`
3. Run the application: `python greet.py`
4. Visit http://localhost:8080 to view the greeting.
5. To change name in greeting, send a POST request

```
curl -X POST -H "Content-Type: application/json" -d "{\"name\": \"Sid\"}" http://localhost:8080
```

## Containerization
- Use the provided Dockerfile to build a Docker image.

## Infrastructure Provision
- Use the provided Terraform configuration to provision infrastructure on AWS.
```
cd infra/
terraform init
terraform plan
terraform apply --auto-approve
```

## CICD JOB Setup
- Jenkins(Dashboard) > Create New Job > Configure > Pipeline > Jenkinsfile.

## Kubernetes Deployment
- Apply the provided Kubernetes YAML files for deployment, service, and ingress.
- Apply the kubernetes deployment: `kubectl apply -f kube/deploy.yaml `

## Helm Chart for Kubernetes Deployment
- Modify values.yaml as needed.
- Install the Helm chart: `helm install greet-app chart/greet-app `

## Accessing the Application
- The application will be accessible at https://greeting-api.acme.co
