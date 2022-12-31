[%{ for key, value in fields }
	{
		"name": "${key}",
		"mode": "${value.mode}",
		"type": "${value.type}"%{ for k, v in confidential_tags }%{ if "${key}"=="${k}" },
		"policyTags": {
			"names": [
				"${lookup("${pt_confidential}", "${key}")}"
			]
		}%{ endif }%{ endfor }%{ for k, v in private_tags }%{ if "${key}"=="${k}" },
		"policyTags": {
			"names": [
				"${lookup("${pt_private}", "${key}")}"
			]
		}%{ endif }%{ endfor }%{ for k, v in sensitive_tags }%{ if "${key}"=="${k}" },
		"policyTags": {
			"names": [
				"${lookup("${pt_sensitive}", "${key}")}"
			]
		}%{ endif }%{ endfor }
	}%{ if "${index(keys(fields), key)}"<"${length(fields)}"-1 },%{ endif }%{ endfor }
]