import nodemailer from "nodemailer"
import { readFileSync } from "fs"
import handlebars from "handlebars"
import path from "path"

import { getDocsByField } from "@/utils/Api_SeverSideCon"
import { IDeployment, IEmailOptions } from "@/utils/types"
import { envOrFail } from "@/utils/env"
import { getSecretKeyValue } from "@/pages/api/secret"

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
  const recipients = [] as string[]
  const server = `https://${GCP_PROJECT_ID}.uc.r.appspot.com`

  const [settings] = await getDocsByField(
    "settings",
    "projectId",
    GCP_PROJECT_ID,
  )
  // verifying email_notifications enabled by admin
  if (!settings.variables.email_notifications) {
    return
  }
  //fetch mailbox password from secret manager
  const password = await getSecretKeyValue("mailBoxCred")
  if (!password) {
    console.error("No email password found")
    return
  }

  // adding module creator/deployer to recipients list
  recipients.push(deployedByEmail)

  if (variables.trusted_users) {
    recipients.push(...variables.trusted_users)
  }
  if (variables.trusted_groups) {
    recipients.push(...variables.trusted_groups)
  }
  if (variables.owner_users) {
    recipients.push(...variables.owner_users)
  }
  if (variables.owner_groups) {
    recipients.push(...variables.owner_groups)
  }

  const configDirectory = path.resolve(process.cwd(), "public")

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
      credentials: {
        email: settings.variables.mail_box_email,
        password,
      },
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
      credentials: {
        email: settings.variables.mail_box_email,
        password,
      },
    }

    await sendMail(mailOptions)
  }
}

export const sendMail = async (emailOptions: IEmailOptions) => {
  const { recipients, credentials } = emailOptions
  if (!recipients.length) {
    return
  }

  const uniqueRecipients = recipients.filter(
    (item, index) => recipients.indexOf(item) === index,
  )

  let transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: credentials.email,
      pass: credentials.password,
    },
  })

  transporter.verify().then(console.log).catch(console.error)

  const mailConfiguration = {
    from: credentials.email,
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
