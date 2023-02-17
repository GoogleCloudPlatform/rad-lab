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
const { CloudBuildClient } = require("@google-cloud/cloudbuild")
const { getFirestore, Timestamp } = require("firebase-admin/firestore")

const envOrFail = (name) => {
  const env = process.env[name]
  if (!env) throw new Error(`${name} is not set`)
  return env
}

const CLOUD_BUILD_PROJECT_ID = envOrFail("PROJECT_ID")
const TRIGGER_ID = envOrFail("TRIGGER_ID")

admin.initializeApp()

const db = getFirestore()
const cloudBuild = new CloudBuildClient()

exports.deleteRadLabModule = (message, context) => {
  const messageData = JSON.parse(Buffer.from(message.data, "base64").toString())

  let deploymentId = messageData.deploymentId
  let moduleName = messageData.variables.module_name
  const user = messageData.user

  console.log(`Deleting RAD Lab module with deployment ID: ${deploymentId}`)

  const request = {
    projectId: CLOUD_BUILD_PROJECT_ID,
    triggerId: TRIGGER_ID,
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
    // This has to be updated with the code to update Firestore with the buildId
    console.log(`Build ID: ${buildId}`)

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
          action: "DELETE",
          user,
          status: "QUEUED",
          createdAt: Timestamp.now(),
        }
        documentData.builds.push(newBuild)
        return deployment.ref
          .update(documentData)
          .then(() => {
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
}
