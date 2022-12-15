[{
		"name": "email",
		"mode": "NULLABLE",
		"type": "STRING"
	},
	{
		"name": "name",
		"mode": "NULLABLE",
		"type": "STRING",
		"policyTags": {
			"names": [
				"${pt_name}"
			]
		}
	},
	{
		"name": "street",
		"mode": "NULLABLE",
		"type": "STRING"
	},
	{
		"name": "city",
		"mode": "NULLABLE",
		"type": "STRING"
	},
	{
		"name": "state",
		"mode": "NULLABLE",
		"type": "STRING"
	},
	{
		"name": "zip",
		"mode": "NULLABLE",
		"type": "INTEGER"
	},
	{
		"name": "dob",
		"mode": "NULLABLE",
		"type": "DATE",
		"policyTags": {
			"names": [
				"${pt_dob}"
			]
		}
	},
	{
		"name": "dl_id",
		"mode": "NULLABLE",
		"type": "STRING",
		"policyTags": {
			"names": [
				"${pt_dlid}"
			]
		}
	},
	{
		"name": "exp_date",
		"mode": "NULLABLE",
		"type": "DATE"
	}
]