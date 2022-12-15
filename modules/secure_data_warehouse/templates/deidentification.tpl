{
    "deidentifyTemplate": {
        displayName: "${display_name}",
        description: "${description}",
        "deidentifyConfig": {
            "recordTransformations": {
                "fieldTransformations": [
                    {
                        "fields": [
                            {
                                "name": "email"
                            },
                            {
                                "name": "dl_id"
                            }
                        ],
                        "primitiveTransformation": {
                            "cryptoDeterministicConfig": {
                                "cryptoKey": {
                                    "kmsWrapped": {
                                        "cryptoKeyName": "${crypto_key}",
                                        "wrappedKey": "${wrapped_key}"
                                    }
                                },
                            }
                        }
                    }
                ]
            }
        }
    },
    "templateId": "${template_id}"
}