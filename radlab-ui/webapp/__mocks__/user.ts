import { User } from 'firebase/auth'

const user: User = {
  uid: '1',
  displayName: 'John Doe',
  email: 'jd@example.com',
  emailVerified: true,
  phoneNumber: '123456789',
  photoURL: 'https://lh3.googleusercontent.com/a-/AOh14GgeGwCRNIALP_N6QtZHVwZv-DFDorGkHNYNL8s=s96-c',
  tenantId: null,
  reload: () => Promise.resolve(),
  isAnonymous: false,
  metadata: {},
  providerId: 'google',
  providerData: [],
  refreshToken: '',
  getIdToken: () => Promise.resolve(''),
  getIdTokenResult: () => Promise.resolve({
    authTime: '',
    expirationTime: '',
    issuedAtTime: '',
    signInProvider: null,
    signInSecondFactor: null,
    token: '',
    claims: {},
  }),
  delete: () => Promise.resolve(),
  toJSON: () => ({}),
}

export default user
