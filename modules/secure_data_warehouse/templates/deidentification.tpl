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
                            "cryptoReplaceFfxFpeConfig": {
                                "cryptoKey": {
                                    "kmsWrapped": {
                                        "cryptoKeyName": "${crypto_key}",
                                        "wrappedKey": "${wrapped_key}"
                                    }
                                },
                                "commonAlphabet": "ALPHA_NUMERIC"
                            }
                        }
                    }
                ]
            }
        }
    },
    "templateId": "${template_id}"
}