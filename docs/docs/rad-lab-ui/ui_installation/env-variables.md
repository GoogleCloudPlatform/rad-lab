---
title: 07 - Environment Variables
sidebar_position: 7
---

Environment variables are kept in .env files.

There are three environments: development, test, and production. Each has its own environment file `.env.development`, `.env.test`, and `.env.production`, respectively. The `.env.development` file is used for local development, the `.env.test` for unit tests (in a CI environment), and the `.env.production` file is used for deploying RAD Lab UI.

If you have sensitive environment variables that you want to keep out of source control, place them in the `.env.development.local`, `.env.test.local`, and `.env.production.local` files. All `.env*.local` files are kept out of source control, but are merged in with their non-local variants when developing, testing, or deploying.

## Firebase envs

Firebase environment variables can be found in project settings section of your Firebase project console: https://console.firebase.google.com/[your-project-id]

- `NEXT_PUBLIC_FIREBASE_PUBLIC_API_KEY`
- `NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN`
- `NEXT_PUBLIC_FIREBASE_PROJECT_ID`
- `NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET`
- `NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID`
- `NEXT_PUBLIC_FIREBASE_APP_ID`
- `NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID`
- `NEXT_PUBLIC_FIREBASE_DATABASE_URL`

## Google Cloud Platform envs

- `NEXT_PUBLIC_GCP_SERVICE_ACCOUNT_EMAIL` - Service account id of your project
- `NEXT_PUBLIC_GCP_PROJECT_ID` - Google Cloud project id
- `NEXT_PUBLIC_GCP_ORGANIZATION` - Domain name of your organization
- `NEXT_PUBLIC_PUBSUB_DEPLOYMENTS_TOPIC` - Topic created via terraform to create and update deployment
- `NEXT_PUBLIC_PUBSUB_DEPLOYMENTS_DELETE_TOPIC` - Topic created via terraform to delete deployment
- `NEXT_PUBLIC_RAD_LAB_ADMIN_GROUP` - Users needs to be added to admin group created on google admin and mention the group name here
- `NEXT_PUBLIC_RAD_LAB_USER_GROUP` - Users needs to be added to user group created on google admin and mention the group name here
- `MODULE_DEPLOYMENT_BUCKET_NAME` - Google Cloud bucket name created via terraform
- `NEXT_PUBLIC_NOTIFICATION_TOPIC` - Topic created for notifications
- `NEXT_PUBLIC_NOTIFICATION_SUB` - Subscription created for notifications
- `NEXT_PUBLIC_GIT_API_URL` - Url of the public repo to pull the deployment modules
- `SECRET_MANAGER_LOCATION` - Location of the Google secret manager to store the secrets(replica set)

## Git Hub repo envs

- `GIT_TOKEN_SECRET_KEY_NAME` - Secret key name of Github Personal Access Token used when setting up RAD Lab UI
