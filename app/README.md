# Threat Composer (application source)

This folder contains the application that the project deploys: [Threat Composer](https://github.com/awslabs/threat-composer), an open-source threat modelling tool from AWS Labs, licensed under Apache-2.0 (see `LICENSE` in this folder and `NOTICE` in the repository root).

The code here is the application as it was provided with the assignment. The one file added for this project is `nginx.conf`, which configures the web server inside the container image.

## Where this came from

The source was provided as part of a CoderCo assignment. The assignment asked for the app to be containerised and hosted on AWS ECS with Terraform, behind HTTPS on a custom domain. This repository does the same job on Azure instead: the image is stored in Azure Container Registry and runs on Azure Container Apps behind an Application Gateway. See the [root README](../README.md) for the architecture and how it is deployed.

## Running the app locally

Without Docker:

```bash
yarn install
yarn build
yarn global add serve
serve -s build
```

Then open http://localhost:3000.

With Docker, from the repository root:

```bash
docker build -f Dockerfile -t tm:local ./app
docker run --rm -p 8080:8080 tm:local
```

Then open http://localhost:8080. The health endpoint is at http://localhost:8080/health.
