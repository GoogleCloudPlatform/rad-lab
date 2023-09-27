---
sidebar_position: 4
---
# Troubleshooting

Please feel free to reach out and to create a [GitHub issue](https://github.com/GoogleCloudPlatform/rad-lab/issues) in case of any issues or concerns.

## Email Notifications
You can optionally enable RAD Lab notification for deployment events. This includes deployment creations, updates, and deletions.

If enabled, the following users/groups (defined in the module's Terraform variables) will receive email notifications:
- The individual taking the action
- `trusted_users`
- `trusted_groups`
- `owner_users`
- `owner_groups`

Currently only sending via gmail is supported. It is recommended to [create a new gmail address](https://support.google.com/mail/answer/56256?hl=en) for this purpose only and generate a `App Password` to authenticate it by followig [Sign in with app passwords](https://support.google.com/mail/answer/185833?hl=en)

 You will then provide this email and its password to RAD Lab UI via the `Global Variables` setup.

The email address will be store in Firestore, and email password will be securely stored in Google's [Secret Manager](https://cloud.google.com/secret-manager)

