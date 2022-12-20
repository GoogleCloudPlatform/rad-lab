import admin from "firebase-admin"
import { getFirestore } from "firebase-admin/firestore"

if (admin.apps.length === 0) {
  admin.initializeApp()
}
const db = getFirestore()
export { db }
