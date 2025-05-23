script_echo "Google Cloud setup..."

#NAME
#    gcloud cheat-sheet - display gcloud cheat sheet

#SYNOPSIS
#    gcloud cheat-sheet [GCLOUD_WIDE_FLAG ...]

#DESCRIPTION
#    A roster of go-to gcloud commands for the gcloud tool, Google Cloud's
#    primary command-line tool.

#  Getting started
#    Get going with the gcloud command-line tool

#      ▪ gcloud init: Initialize, authorize, and configure the gcloud tool.
#      ▪ gcloud version: Display version and installed components.
#      ▪ gcloud components install: Install specific components.
#      ▪ gcloud components update: Update your Google Cloud CLI to the latest
#        version.
#      ▪ gcloud config set project: Set a default Google Cloud project to work
#        on.
#      ▪ gcloud info: Display current gcloud tool environment details.

#  Help
#    Google Cloud CLI is happy to help

#      ▪ gcloud help: Search the gcloud tool reference documents for specific
#        terms.
#      ▪ gcloud feedback: Provide feedback for the Google Cloud CLI team.
#      ▪ gcloud topic: Supplementary help material for non-command topics like
#        accessibility, filtering, and formatting.

#  Personalization
#    Make the Google Cloud CLI your own; personalize your configuration with
#    properties

#      ▪ gcloud config set: Define a property (like compute/zone) for the
#        current configuration.
#      ▪ gcloud config get: Fetch value of a Google Cloud CLI property.
#      ▪ gcloud config list: Display all the properties for the current
#        configuration.
#      ▪ gcloud config configurations create: Create a new named
#        configuration.
#      ▪ gcloud config configurations list: Display a list of all available
#        configurations.
#      ▪ gcloud config configurations activate: Switch to an existing named
#        configuration.

#  Credentials
#    Grant and revoke authorization to Google Cloud CLI

#      ▪ gcloud auth login: Authorize Google Cloud access for the gcloud tool
#        with Google user credentials and set current account as active.
#      ▪ gcloud auth activate-service-account: Like gcloud auth login but with
#        service account credentials.
#      ▪ gcloud auth list: List all credentialed accounts.
#      ▪ gcloud auth print-access-token: Display the current account's access
#        token.
#      ▪ gcloud auth revoke: Remove access credentials for an account.

#  Projects
#    Manage project access policies

#      ▪ gcloud projects describe: Display metadata for a project (including
#        its ID).
#      ▪ gcloud projects add-iam-policy-binding: Add an IAM policy binding to
#        a specified project.

#  Identity & Access Management
#    Configuring Cloud Identity & Access Management (IAM) preferences and
#    service accounts

#      ▪ gcloud iam list-grantable-roles: List IAM grantable roles for a
#        resource.
#      ▪ gcloud iam roles create: Create a custom role for a project or org.
#      ▪ gcloud iam service-accounts create: Create a service account for a
#        project.
#      ▪ gcloud iam service-accounts add-iam-policy-binding: Add an IAM policy
#        binding to a service account.
#      ▪ gcloud iam service-accounts set-iam-policy: Replace existing IAM
#        policy binding.
#      ▪ gcloud iam service-accounts keys list: List a service account's keys.

#  Docker & Google Kubernetes Engine (GKE)
#    Manage containerized applications on Kubernetes

#      ▪ gcloud auth configure-docker: Register the gcloud tool as a Docker
#        credential helper.
#      ▪ gcloud container clusters create: Create a cluster to run GKE
#        containers.
#      ▪ gcloud container clusters list: List clusters for running GKE
#        containers.
#      ▪ gcloud container clusters get-credentials: Update kubeconfig to get
#        kubectl to use a GKE cluster.
#      ▪ gcloud container images list-tags: List tag and digest metadata for a
#        container image.

#  Virtual Machines & Compute Engine
#    Create, run, and manage VMs on Google infrastructure

#      ▪ gcloud compute zones list: List Compute Engine zones.
#      ▪ gcloud compute instances describe: Display a VM instance's details.
#      ▪ gcloud compute instances list: List all VM instances in a project.
#      ▪ gcloud compute disks snapshot: Create snapshot of persistent disks.
#      ▪ gcloud compute snapshots describe: Display a snapshot's details.
#      ▪ gcloud compute snapshots delete: Delete a snapshot.
#      ▪ gcloud compute ssh: Connect to a VM instance by using SSH.

#  Serverless & App Engine
#    Build highly scalable applications on a fully managed serverless platform

#      ▪ gcloud app deploy: Deploy your app's code and configuration to the
#        App Engine server.
#      ▪ gcloud app versions list: List all versions of all services deployed
#        to the App Engine server.
#      ▪ gcloud app browse: Open the current app in a web browser.
#      ▪ gcloud app create: Create an App Engine app within your current
#        project.
#      ▪ gcloud app logs read: Display the latest App Engine app logs.

#  Miscellaneous
#    Commands that might come in handy

#      ▪ gcloud kms decrypt: Decrypt ciphertext (to a plaintext file) using a
#        Cloud Key Management Service (Cloud KMS) key.
#      ▪ gcloud logging logs list: List your project's logs.
#      ▪ gcloud sql backups describe: Display info about a Cloud SQL instance
#        backup.
#      ▪ gcloud sql export sql: Export data from a Cloud SQL instance to a SQL
#        file.

#EXAMPLES
#    To view this cheat sheet, run:

#        $ gcloud cheat-sheet

#GCLOUD WIDE FLAGS
#    These flags are available to all commands: --access-token-file, --account,
#    --billing-project, --configuration, --flags-file, --flatten, --format,
#    --help, --impersonate-service-account, --log-http, --project, --quiet,
#    --trace-token, --user-output-enabled, --verbosity.

#    Run $ gcloud help for details.

## Java integration
# Map GCP_ prefixed environment variables to gcp. system properties
#if [ ! -z "${GCP_KMS_PROJECT_ID}" ]; then
#  JAVA_OPTS="${JAVA_OPTS} -Dgcp.kms.project-id=${GCP_KMS_PROJECT_ID}"
#fi
#if [ ! -z "${GCP_KMS_LOCATION_ID}" ]; then
#  JAVA_OPTS="${JAVA_OPTS} -Dgcp.kms.location-id=${GCP_KMS_LOCATION_ID}"
#fi
#if [ ! -z "${GCP_KMS_KEYRING_ID}" ]; then
#  JAVA_OPTS="${JAVA_OPTS} -Dgcp.kms.keyring-id=${GCP_KMS_KEYRING_ID}"
#fi
#if [ ! -z "${GCP_KMS_ENCRYPTION_KEY_ID}" ]; then
#  JAVA_OPTS="${JAVA_OPTS} -Dgcp.kms.encryption-key-id=${GCP_KMS_ENCRYPTION_KEY_ID}"
#fi
#if [ ! -z "${GCP_KMS_PASSWORD_PEPPER_ID}" ]; then
#  JAVA_OPTS="${JAVA_OPTS} -Dgcp.kms.password-pepper-id=${GCP_KMS_PASSWORD_PEPPER_ID}"
#fi
#if [ ! -z "${GCP_SECRETMANAGER_PROJECT_ID}" ]; then
#  JAVA_OPTS="${JAVA_OPTS} -Dgcp.secretmanager.project-id=${GCP_SECRETMANAGER_PROJECT_ID}"
#fi

# Pass GCP authentication token if provided
#if [ ! -z "${GOOGLE_OAUTH_ACCESS_TOKEN}" ]; then
#  log_info "Using provided GOOGLE_OAUTH_ACCESS_TOKEN for authentication"
#  JAVA_OPTS="${JAVA_OPTS} -Dgoogle.oauth.access.token=${GOOGLE_OAUTH_ACCESS_TOKEN}"
#fi

## Set default GCP KMS values for QA environment if not provided
#if [ -z "${GCP_KMS_PROJECT_ID}" ]; then
#  log_warn "GCP_KMS_PROJECT_ID not set, using default agora-455601"
#  export GCP_KMS_PROJECT_ID="agora-455601"
#  JAVA_OPTS="${JAVA_OPTS} -Dgcp.kms.project-id=agora-455601"
#fi
#if [ -z "${GCP_KMS_LOCATION_ID}" ]; then
#  log_warn "GCP_KMS_LOCATION_ID not set, using default us-central1"
#  export GCP_KMS_LOCATION_ID="us-central1"
#  JAVA_OPTS="${JAVA_OPTS} -Dgcp.kms.location-id=us-central1"
#fi
#if [ -z "${GCP_KMS_KEYRING_ID}" ]; then
#  log_warn "GCP_KMS_KEYRING_ID not set, using default agora-qa-keyring"
#  export GCP_KMS_KEYRING_ID="agora-qa-keyring"
#  JAVA_OPTS="${JAVA_OPTS} -Dgcp.kms.keyring-id=agora-qa-keyring"
#fi
#if [ -z "${GCP_KMS_ENCRYPTION_KEY_ID}" ]; then
#  log_warn "GCP_KMS_ENCRYPTION_KEY_ID not set, using default agora-encryption-key-qa"
#  export GCP_KMS_ENCRYPTION_KEY_ID="agora-encryption-key-qa"
#  JAVA_OPTS="${JAVA_OPTS} -Dgcp.kms.encryption-key-id=agora-encryption-key-qa"
#fi
#if [ -z "${GCP_KMS_PASSWORD_PEPPER_ID}" ]; then
#  log_warn "GCP_KMS_PASSWORD_PEPPER_ID not set, using default agora-password-pepper-qa"
#  export GCP_KMS_PASSWORD_PEPPER_ID="agora-password-pepper-qa"
#  JAVA_OPTS="${JAVA_OPTS} -Dgcp.kms.password-pepper-id=agora-password-pepper-qa"
#fi
#log_info "KMS Project: ${GCP_KMS_PROJECT_ID}"
#log_info "KMS Location: ${GCP_KMS_LOCATION_ID}"
#log_info "KMS Keyring: ${GCP_KMS_KEYRING_ID}"
#log_info "KMS Encryption Key ID: ${GCP_KMS_ENCRYPTION_KEY_ID}"
#log_info "KMS Password Pepper ID: ${GCP_KMS_PASSWORD_PEPPER_ID}"


alias gc=gcloud
alias gc_project="gcloud config list --format='text(core.project)'"

gcloud --version