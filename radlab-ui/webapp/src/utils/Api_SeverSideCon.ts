import { db } from "@/pages/api/firebaseAdminConnection"
import { IBuild, IDeployment } from "@/utils/types"
import { Timestamp } from "firebase-admin/firestore"

export const getAllDocuments = async (collection: string) => {
  const res: any = []
  const snapshot = await db.collection(collection).get()
  snapshot.forEach((doc: any) => {
    res.push({ id: doc.id, ...doc.data() })
  })
  return res
}

export const saveDocument = async (
  collectionName: string,
  body: Record<string, any>,
  id?: string,
) => {
  if (!id) body.createdAt = Timestamp.now()
  body.updatedAt = Timestamp.now()
  const collection = db.collection(collectionName)
  const doc = id ? collection.doc(id) : collection.doc()
  await doc.set(body)
  const docRef = db.collection(collectionName).doc(doc.id)
  const res = await docRef.get()
  return { ...res.data(), id: doc.id }
}

export const getDocsByField = async (
  collection: string,
  field: string,
  value: string,
) => {
  const res: any = []
  const snapshot = await db
    .collection(collection)
    .where(field, "==", value)
    .get()
  snapshot.forEach((doc: any) => {
    const document = {
      id: doc.id,
      ...doc.data(),
    }
    res.push(document)
  })
  return res
}

export const updateByField = async (
  collection: string,
  field: string,
  value: string,
  body: Record<string, any>,
) => {
  const docs = await getDocsByField(collection, field, value)
  body.createdAt = docs.createdAt
  return docs.forEach((doc: any) => {
    body.createdAt = doc.createdAt
    body.projectId = doc.projectId
    body.deploymentId = doc.deploymentId
    body.builds = doc.builds
    saveDocument(collection, { ...doc, ...body }, doc.id)
  })
}

export const deleteDocByFieldValue = async (
  collection: string,
  field: string,
  value: string,
) =>
  db
    .collection(collection)
    .where(field, "==", value)
    .get()
    .then((query) => query.docs.forEach((doc) => doc.ref.delete()))

export const deleteDocumentById = async (collection: string, id: string) => {
  return db.collection(collection).doc(id).delete()
}

export const updateBuildStatus = async (
  deploymentId: string,
  body: Record<string, any>,
) => {
  const deployments = await getDocsByField(
    "deployments",
    "deploymentId",
    deploymentId,
  )
  return deployments.forEach((doc: IDeployment) => {
    body.createdAt = doc.createdAt
    body.projectId = doc.projectId
    body.deploymentId = doc.deploymentId
    const builds = doc.builds
    ;(builds || []).forEach((build: IBuild) => {
      if (build.buildId === body.buildId) {
        build.status = body.status
      }
    })
    body.builds = builds
    return saveDocument("deployments", { ...doc, ...body }, doc.id)
  })
}

export const canAccessDeployment = (
  deployment: IDeployment,
  userEmail: string,
  isAdmin: boolean,
) => isAdmin || isCreatorOfDeployment(deployment, userEmail)

export const isCreatorOfDeployment = (
  deployment: IDeployment,
  userEmail: string,
) => deployment.deployedByEmail === userEmail

export const isCreatorOfDeploymentById = async (
  deployId: string,
  userEmail: string,
) => {
  let [deployment]: [IDeployment] = await getDocsByField(
    "deployments",
    "deploymentId",
    deployId,
  )

  if (!deployment) {
    return false
  }

  return isCreatorOfDeployment(deployment, userEmail)
}
