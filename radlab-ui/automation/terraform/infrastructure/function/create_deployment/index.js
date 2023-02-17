/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * Exports a Cloud Function that creates a Build for a RAD Lab module and
 * updates Firestore with the new Cloud Build ID.
 */

"use strict"

const admin = require("firebase-admin")
const {CloudBuildClient} = require("@google-cloud/cloudbuild")
const {getFirestore, Timestamp} = require("firebase-admin/firestore")
const {Storage} = require("@google-cloud/storage")

const envOrFail = (name) => {
  const env = process.env[name]
  if (!env) throw new Error(`${name} is not set`)
  return env
}

const CLOUD_BUILD_PROJECT_ID = envOrFail("PROJECT_ID")
const CREATE_TRIGGER_ID = envOrFail("CREATE_TRIGGER_ID")
const UPDATE_TRIGGER_ID = envOrFail("UPDATE_TRIGGER_ID")
const DEPLOYMENTS_BUCKET_NAME = envOrFail("DEPLOYMENT_BUCKET_NAME")
const PARENT_FOLDER_ID = envOrFail("PARENT_FOLDER_ID")

admin.initializeApp()

const cloudBuild = new CloudBuildClient()
const storage = new Storage()
const db = getFirestore()

exports.createRadLabModule = (message, context) => {
  const messageData = JSON.parse(Buffer.from(message.data, "base64").toString())

  let action = messageData.action
  let deploymentId = messageData.deploymentId
  let moduleName = messageData.module

  const user = messageData.user

  messageData.variables.folder_id = `folders/${PARENT_FOLDER_ID}`

  if (!messageData.variables.trusted_users.includes(user)) {
    messageData.variables.trusted_users.push(user);
  }

  let triggerName = "";

  if (action === "CREATE") {
    console.log(
      `Creating new module, ${moduleName} with deployment ID ${deploymentId}`,
    )
    triggerName = CREATE_TRIGGER_ID
    let backendConfig = `terraform {
      backend "gcs" {
        bucket = "${DEPLOYMENTS_BUCKET_NAME}"
        prefix = "deployments/${moduleName}_${deploymentId}/state/"
      }
    }`

    storage
      .bucket(DEPLOYMENTS_BUCKET_NAME)
      .file(`deployments/${moduleName}_${deploymentId}/files/backend.tf`)
      .save(backendConfig)
  } else {
    console.log(
      `Updating module, ${moduleName} with deployment ID ${deploymentId}`,
    )
    triggerName = UPDATE_TRIGGER_ID
  }

  return storage
    .bucket(DEPLOYMENTS_BUCKET_NAME)
    .file(
      `deployments/${moduleName}_${deploymentId}/files/terraform.tfvars.json`,
    )
    .save(JSON.stringify(messageData.variables, null, 2))
    .then((result) => {
      const request = {
        projectId: CLOUD_BUILD_PROJECT_ID,
        triggerId: triggerName,
        source: {
          substitutions: {
            _MODULE_NAME: moduleName,
            _DEPLOYMENT_ID: deploymentId,
          },
        },
      }

      return cloudBuild.runBuildTrigger(request).then((result) => {
        let metadata = result[0].metadata
        let buildId = metadata.build.id

        return db
          .collection("deployments")
          .where("deploymentId", "==", deploymentId.toString())
          .get()
          .then((query) => {
            const deployment = query.docs[0]
            if (!deployment)
              throw new Error(`Could not find deployment for ${deploymentId}`)
            let documentData = deployment.data()
            const newBuild = {
              buildId,
              action,
              user,
              status: "QUEUED",
              createdAt: Timestamp.now(),
            }
            documentData.builds.push(newBuild)
            return deployment.ref
              .update(documentData)
              .then((result) => {
                console.log(
                  `Deployment with ID ${deploymentId} updated with build ID ${buildId}.`,
                )
              })
              .catch((error) => {
                console.error(
                  "Exception while storing Build ID in Firestore",
                  error,
                )
              })
          })
          .catch((error) => {
            console.error(
              `Exception while retrieving the document for deployment ID ${deploymentId}`,
              error,
            )
          })
      })
    })
}
