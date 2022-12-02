import { useTranslation } from "next-i18next"
import {
  signInWithPopup,
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
} from "firebase/auth"
import { auth, googleProvider } from "@/utils/firebase"
import { useRouter } from "next/router"
import Link from "next/link"
import { IAuthProvider, isAdminResponseParser, Settings } from "@/utils/types"
import { userStore } from "@/store"
import { useState } from "react"
import { classNames } from "@/utils/dom"
import Loading from "@/navigation/Loading"
import { ErrorMessage, Formik, Form, Field } from "formik"
import { object, string } from "yup"
import { ArrowRightIcon } from "@heroicons/react/outline"
import axios from "axios"

interface SignInFormProps {
  authOptions: IAuthProvider[]
}

const passwordSchema = object({
  email: string().required("Email is required").email(),
  password: string()
    .required("Password is required")
    .min(8, "Must be at least 8 characters"),
})

type PasswordFields = {
  email: string
  password: string
}

const defaultPasswordFormValues: PasswordFields = {
  email: "",
  password: "",
}

const SignInForm: React.FC<SignInFormProps> = ({ authOptions }) => {
  const { t: ts } = useTranslation("signin")
  const router = useRouter()

  const [submittingGoogle, setSubmittingGoogle] = useState(false)
  const [submittingPassword, setSubmittingPassword] = useState(false)
  const [passwordError, setPasswordError] = useState<string | null>(null)
  const setUser = userStore((state) => state.setUser)

  const AUTH_ERROR_MESSAGES = {
    "auth/operation-not-allowed":
      "Ask your developer to enable this signin method.",
    "auth/wrong-password":
      "Wrong user/password combination, or you previously used a different signin method.",
    "auth/user-not-found": "",
    default: "Uh oh! Something went wrong.",
  }

  const signInWithGoogle = async () => {
    setPasswordError(null)
    setSubmittingGoogle(true)

    try {
      const { user } = await signInWithPopup(auth, googleProvider)
      if (!user.email) throw new Error("User is missing email")
      setUser({
        ...user,
        email: user.email,
      })
      Promise.all([
        axios.get(`/api/user?email=${user.email}`),
        axios.get(`/api/settings`),
      ])
        .then(([adminCheck, adminSettings]) => {
          const admin = isAdminResponseParser.parse(adminCheck.data)
          const settings = Settings.parse(adminSettings.data.settings)
          if (admin.isAdmin === false) {
            router.push("/")
          } else {
            if (!settings) router.push("/admin")
            else router.push("/deployments")
          }
        })
        .catch((error) => {
          console.error(error)
          router.push("/")
        })
    } catch (error) {
      console.error(error)
      setSubmittingGoogle(false)
    }
  }

  const signInWithPassword = ({ email, password }: PasswordFields) => {
    setPasswordError(null)
    setSubmittingPassword(true)

    signInWithEmailAndPassword(auth, email, password)
      .catch((error) => {
        if (error.code === "auth/user-not-found") {
          // User has not been created
          return createUserWithEmailAndPassword(auth, email, password)
        }
        throw error
      })
      .then((userCred) => {
        setUser(userCred.user)
        router.push("/")
      })
      .catch((error) => {
        setPasswordError(
          // @ts-ignore
          AUTH_ERROR_MESSAGES[error?.code || "default"] ??
            AUTH_ERROR_MESSAGES.default,
        )
        console.error(error)
        setSubmittingPassword(false)
      })
  }

  const renderGoogle = () => (
    <button
      onClick={signInWithGoogle}
      disabled={submittingGoogle}
      className={classNames(
        "btn bg-base-100 w-full shadow-lg border-base-300",
        submittingGoogle
          ? "cursor-not-allowed text-base-content"
          : "cursor-pointer hover:border-primary hover:bg-base-100",
      )}
    >
      {submittingGoogle ? (
        <div className="mr-4">
          <Loading />
        </div>
      ) : (
        <img
          className="h-8 w-auto mr-4"
          src="/assets/images/google.png"
          alt="Google"
        />
      )}
      <div className="font-semibold text-base-content">
        {ts("signin-google")}
      </div>
    </button>
  )

  const renderPassword = () => (
    <div>
      <div className="flex justify-center relative mb-2 mt-1">
        <div className="absolute w-full top-1/2 border-b border-base-300"></div>
        <div className="bg-base-100 px-4 z-10 text-faint text-center">
          {ts("signin-password")}
        </div>
      </div>

      {passwordError ? (
        <div className="border border-error bg-error bg-opacity-10 text-error rounded-lg my-4 px-2 py-1">
          {passwordError}
        </div>
      ) : (
        <></>
      )}

      <Formik
        initialValues={defaultPasswordFormValues}
        validationSchema={passwordSchema}
        onSubmit={signInWithPassword}
      >
        <Form>
          <div className="form-control">
            <label htmlFor="email" className="text-left">
              {ts("email")}
            </label>
            <Field
              id="email"
              name="email"
              className="input"
              autoComplete="email"
            />
            <div className="invalid-feedback text-left">
              <ErrorMessage name="email" />
            </div>
          </div>

          <div className="form-control">
            <label htmlFor="password" className="text-left">
              {ts("password")}
            </label>
            <Field
              type="password"
              id="password"
              name="password"
              className="input"
              autoComplete="current-password"
            />
            <div className="invalid-feedback text-left">
              <ErrorMessage name="password" />
            </div>
          </div>

          <div className="flex justify-between items-center">
            <Link href={"/password-reset"}>
              <a className="text-sm">Forgot password?</a>
            </Link>

            <button
              className="btn btn-primary"
              type="submit"
              disabled={submittingPassword}
            >
              {submittingPassword ? (
                <div className="flex items-center justify-center w-20">
                  <Loading />
                </div>
              ) : (
                <div className="flex items-center justify-center w-20">
                  {ts("signin")}
                  <ArrowRightIcon className="w-4 ml-2" />
                </div>
              )}
            </button>
          </div>
        </Form>
      </Formik>
      <div className="flex items-center justify-center font-bold mt-4">Or</div>
    </div>
  )

  return (
    <div className="gap-y-4 grid grid-cols-1">
      {authOptions.includes("password") ? renderPassword() : <></>}
      {authOptions.includes("google") ? renderGoogle() : <></>}
    </div>
  )
}

export default SignInForm
