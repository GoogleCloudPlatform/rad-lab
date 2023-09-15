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

export const configureEmailAndSend = async (deployment: IDeployment) => {
  const { variables, projectId, module, deploymentId } = deployment
  const recipients = [
    ...variables.trusted_users,
    ...variables.trusted_groups,
    ...variables.owner_users,
    ...variables.owner_groups,
  ] as string[]

  const configDirectory = path.resolve(process.cwd(), "public")

  let html = await readFileSync(
    path.join(configDirectory + "/assets/htmlTemplates/email.html"),
    "utf8",
  )
  let template = await handlebars.compile(html)

  const outputs = [
    {
      name: "projectId",
      value: projectId,
    },
    {
      name: "module",
      value: module,
    },
    {
      name: "deploymentId",
      value: deploymentId,
    },
    {
      name: "billing_account_id",
      value: variables.billing_account_id,
    },
    {
      name: "zone",
      value: variables.zone,
    },
  ]

  let data = {
    outputs,
  }
  let htmlToSend = template(data)

  const mailOptions: IEmailOptions = {
    recipients,
    subject: "RAD Lab Module is Ready!",
    mailBody: htmlToSend,
  }

  await sendMail(mailOptions)
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

export const deleteMailHTML = (deploymentId: string) =>
  `<h3>Hello! </h3> <p>RAD Lab Module with deployment ID - ${deploymentId} has been successfully deleted!</p> Thank you<br /> <b>GPSDemofactory</b> <br/> <p>P.S:- This is an auto generated email!</p>`
