import { sendPasswordResetEmail } from "firebase/auth"
import { auth } from "@/utils/firebase"

import { ErrorMessage, Formik, Form, Field } from "formik"
import { object, string } from "yup"
import { useState } from "react"
import { useTranslation } from "next-i18next"
import Link from "next/link"
import Loading from "@/navigation/Loading"
import { ArrowRightIcon } from "@heroicons/react/outline"

const emailSchema = object({
  email: string().required("Email is required").email(),
})

type EmailFields = {
  email: string
}

const defaultEmailFields: EmailFields = {
  email: "",
}

interface PasswordResetFormProps {}

const PasswordResetForm: React.FC<PasswordResetFormProps> = () => {
  const { t: ts } = useTranslation("signin")
  const [submitting, setSubmitting] = useState(false)
  const [submitted, setSubmitted] = useState(false)

  const resetPassword = async ({ email }: EmailFields) => {
    try {
      setSubmitting(true)
      await sendPasswordResetEmail(auth, email)
      setSubmitted(true)
    } catch (error) {
      console.error(error)
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <div>
      {submitted ? (
        <div className="alert alert-info font-semibold py-2 mb-2 rounded-lg transition">
          {ts("reset-email-sent")}
        </div>
      ) : (
        <></>
      )}

      <Formik
        initialValues={defaultEmailFields}
        validationSchema={emailSchema}
        onSubmit={resetPassword}
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

          <div className="flex justify-between">
            <Link href={"/signin"}>
              <a className="text-sm">{ts("back-to-signin")}</a>
            </Link>

            <button
              className="btn btn-primary"
              type="submit"
              disabled={submitting || submitted}
            >
              {submitting ? (
                <div className="flex items-center justify-center w-20">
                  <Loading />
                </div>
              ) : (
                <div className="flex items-center justify-center w-20">
                  {ts("reset")}
                  <ArrowRightIcon className="w-4 ml-2" />
                </div>
              )}
            </button>
          </div>
        </Form>
      </Formik>
    </div>
  )
}

export default PasswordResetForm
