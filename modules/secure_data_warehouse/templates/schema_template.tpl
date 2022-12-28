[%{ for key, value in fields }
	{
		"name": "${value.name}",
		"mode": "${value.mode}",
		"type": "${value.type}"%{ for k, v in confidential_tags }%{ if "${value.name}"=="${k}" },
		"policyTags": {
			"names": [
				"$${pt_confidential}",
			]
		}%{ endif }%{ endfor }%{ for k, v in private_tags }%{ if "${value.name}"=="${k}" },
		"policyTags": {
			"names": [
				"$${pt_private}",
			]
		}%{ endif }%{ endfor }%{ for k, v in sensitive_tags }%{ if "${value.name}"=="${k}" },
		"policyTags": {
			"names": [
				"$${pt_sensitive}",
			]
		}%{ endif }%{ endfor }
	}%{ if "${index(keys(fields), key)}"<"${length(fields)}"-1 },%{ endif }%{ endfor }
]