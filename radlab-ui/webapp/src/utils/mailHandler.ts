import { IDeployment, IEmailOptions } from "@/utils/types"
import { envOrFail } from "@/utils/env"
import nodemailer from "nodemailer"
import { readFileSync } from "fs"
import handlebars from "handlebars"
import path from "path"

const MAIL_SERVER_USERNAME = envOrFail(
  "MAIL_SERVER_USERNAME",
  process.env.MAIL_SERVER_USERNAME,
)

const MAIL_SERVER_PASS = envOrFail(
  "MAIL_SERVER_PASS",
  process.env.MAIL_SERVER_PASS,
)

const GCP_PROJECT_ID = envOrFail(
  "NEXT_PUBLIC_GCP_PROJECT_ID",
  process.env.NEXT_PUBLIC_GCP_PROJECT_ID,
)

export const configureEmailAndSend = async (
  mailSubject: string,
  deployment: IDeployment,
) => {
  const { variables, projectId, module, deploymentId, deployedByEmail } =
    deployment

  const recipients = [
    ...variables.trusted_users,
    ...variables.trusted_groups,
    ...variables.owner_users,
    ...variables.owner_groups,
  ] as string[]

  recipients.push(deployedByEmail)

  const configDirectory = path.resolve(process.cwd(), "public")
  const server = `https://${GCP_PROJECT_ID}.uc.r.appspot.com`

  if (mailSubject === "RAD Lab Module has been deleted for you!") {
    const html = await readFileSync(
      path.join(configDirectory + "/assets/htmlTemplates/deleteEmail.html"),
      "utf8",
    )
    const template = await handlebars.compile(html)

    const data = {
      deploymentId,
      deploymentLink: `${server}/deployments/${deploymentId}`,
    }

    handlebars.registerHelper("deployment_link", () => {
      return new handlebars.SafeString(
        handlebars.Utils.escapeExpression(data.deploymentLink),
      )
    })

    const htmlToSend = template(data)

    const mailOptions: IEmailOptions = {
      recipients,
      subject: mailSubject,
      mailBody: htmlToSend,
    }

    await sendMail(mailOptions)
  } else {
    const html = await readFileSync(
      path.join(configDirectory + "/assets/htmlTemplates/email.html"),
      "utf8",
    )

    const template = await handlebars.compile(html)

    const billingId = variables.billing_account_id as string

    const maskedBillingId =
      billingId.substring(0, billingId.length - 6).replace(/[a-z\d]/gi, "*") +
      billingId.substring(billingId.length - 6, billingId.length)

    const outputs = [
      {
        name: "module",
        value: module,
      },
      {
        name: "billing_account_id",
        value: maskedBillingId,
      },
      {
        name: "zone",
        value: variables.zone,
      },
    ]

    const data = {
      outputs,
      mailBodyTitle: mailSubject,
      projectId,
      projectLink: `https://console.cloud.google.com/welcome?project=${projectId}`,
      deploymentId,
      deploymentLink: `${server}/deployments/${deploymentId}`,
    }
    handlebars.registerHelper("gcp_project_link", () => {
      return new handlebars.SafeString(
        handlebars.Utils.escapeExpression(data.projectLink),
      )
    })

    handlebars.registerHelper("deployment_link", () => {
      return new handlebars.SafeString(
        handlebars.Utils.escapeExpression(data.deploymentLink),
      )
    })

    const htmlToSend = template(data)

    const mailOptions: IEmailOptions = {
      recipients,
      subject: mailSubject,
      mailBody: htmlToSend,
    }

    await sendMail(mailOptions)
  }
}

export const sendMail = async (emailOptions: IEmailOptions) => {
  const recipients = emailOptions.recipients
  if (!recipients.length) {
    return
  }

  const uniqueRecipients = recipients.filter(
    (item, index) => recipients.indexOf(item) === index,
  )

  let transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: MAIL_SERVER_USERNAME,
      pass: MAIL_SERVER_PASS,
    },
  })

  transporter.verify().then(console.log).catch(console.error)

  const mailConfiguration = {
    from: MAIL_SERVER_USERNAME,
    to: uniqueRecipients.toString(),
    subject: emailOptions.subject,
    html: emailOptions.mailBody,
  }
  transporter
    .sendMail(mailConfiguration)
    .then((res) => {
      console.log("Mail sent", res)
    })
    .catch((error) => {
      console.error("Error", error)
    })
}
