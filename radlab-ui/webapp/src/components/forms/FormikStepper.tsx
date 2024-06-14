import React, { useState } from "react"
import { classNames } from "@/utils/dom"

import { Formik, Form, FormikConfig, FormikValues } from "formik"
import { useParams } from "react-router-dom"

export interface FormikStepProps
  extends Pick<FormikConfig<FormikValues>, "children" | "validationSchema"> {
  label: string
}

export function FormikStep({ children }: FormikStepProps) {
  return <>{children}</>
}

export function FormikStepper({
  children,
  ...props
}: FormikConfig<FormikValues>) {
  const childrenArray = React.Children.toArray(
    children,
  ) as React.ReactElement<FormikStepProps>[]
  const [step, setStep] = useState(0)
  const currentChild = childrenArray[step]
  const [completed, setCompleted] = useState(false)
  const params = useParams()
  const [isSubmitLoading, setSubmitLoading] = useState(false)

  function isLastStep() {
    return step === childrenArray.length - 1
  }

  if (!currentChild) return <div>Missing current child</div>

  return (
    <>
      <Formik
        enableReinitialize
        initialValues={props.initialValues}
        onSubmit={async (values, helpers) => {
          helpers.setSubmitting(false)
          window.scrollTo(0, 0)
          if (isLastStep()) {
            setSubmitLoading(true)
            await props.onSubmit(values, helpers)
            setCompleted(true)
          } else {
            setStep((s) => s + 1)
            helpers.validateForm(props.initialValues)
          }
        }}
        validateOnMount
        isInitialValid
      >
        {({ isSubmitting, isValid }) => (
          <Form autoComplete="off">
            <ul className="steps w-full mb-12">
              {childrenArray.map((child, index) => (
                <li
                  key={index}
                  className={classNames(
                    "step",
                    step + 1 > index || completed ? "step-primary" : "",
                  )}
                >
                  {child.props.label}
                </li>
              ))}
            </ul>
            {currentChild}
            <div className="flex-row justify-center gap-x-4 mt-6">
              {step > 0 ? (
                <button
                  type="button"
                  className="btn btn-outline btn-primary w-32"
                  disabled={isSubmitting || isSubmitLoading}
                  onClick={() => setStep((s) => s - 1)}
                >
                  Previous
                </button>
              ) : null}
              {params.deployId ? (
                <button
                  type="submit"
                  className="btn btn-primary float-right w-32"
                  disabled={!isValid || isSubmitting || isSubmitLoading}
                >
                  {isSubmitting || isSubmitLoading
                    ? "Submitting"
                    : isLastStep()
                    ? "Update"
                    : "Next"}
                </button>
              ) : (
                <button
                  type="submit"
                  className="btn btn-primary float-right w-32"
                  disabled={!isValid || isSubmitting || isSubmitLoading}
                >
                  {isSubmitting || isSubmitLoading
                    ? "Submitting"
                    : isLastStep()
                    ? "Submit"
                    : "Next"}
                </button>
              )}
            </div>
          </Form>
        )}
      </Formik>
    </>
  )
}
