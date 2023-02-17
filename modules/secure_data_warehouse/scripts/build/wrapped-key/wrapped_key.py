# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import argparse
import base64
import crcmod
import six
from google.cloud import kms
import google.auth
from google.auth import impersonated_credentials


def encrypt_symmetric(project_id, location_id, key_ring_id, key_id, client):
    """
    Encrypt securely generated random bytes using a confidential
    computing symmetric key.

    Args:
        project_id (string): Google Cloud project ID.
        location_id (string): Cloud KMS location.
        key_ring_id (string): ID of the Cloud KMS key ring.
        key_id (string): ID of the key to use.
        client (KeyManagementServiceClient):
        Google Cloud Key Management Service.
    Returns:
        bytes: Encrypted ciphertext.
    """

    # Generate random bytes.
    plaintext_bytes = generate_random_bytes(
        project_id, location_id, 32, client)

    # Optional, but recommended: compute plaintext's CRC32C.
    # See crc32c() function defined below.
    plaintext_crc32c = crc32c(plaintext_bytes)

    # Build the key name.
    key_name = client.crypto_key_path(
        project_id, location_id, key_ring_id, key_id)

    # Call the API.
    encrypt_response = client.encrypt(
        request={'name': key_name, 'plaintext': plaintext_bytes,
                 'plaintext_crc32c': plaintext_crc32c})

    # Optional, but recommended: perform integrity verification
    # on encrypt_response.
    # For more details on ensuring E2E in-transit integrity to
    # and from Cloud KMS visit:
    # https://cloud.google.com/kms/docs/data-integrity-guidelines
    if not encrypt_response.verified_plaintext_crc32c:
        raise Exception(
            'The request sent to the server was corrupted in-transit.')
    if not encrypt_response.ciphertext_crc32c == \
            crc32c(encrypt_response.ciphertext):
        raise Exception(
            'The response received from the server was corrupted in-transit.')
    # End integrity verification

    return encrypt_response


def generate_random_bytes(project_id, location_id, num_bytes, client):
    """
    Generate random bytes with entropy sourced from the given location.

    Args:
        project_id (string): Google Cloud project ID (e.g. 'my-project').
        location_id (string): Cloud KMS location (e.g. 'us-east1').
        num_bytes (integer): number of bytes of random data.
        client (KeyManagementServiceClient):
        Google Cloud Key Management Service.

    Returns:
        bytes: Encrypted ciphertext.

    """

    # Build the location name.
    location_name = client.common_location_path(project_id, location_id)

    # Call the API.
    protection_level = kms.ProtectionLevel.HSM
    random_bytes_response = client.generate_random_bytes(
        request={'location': location_name, 'length_bytes': num_bytes,
                 'protection_level': protection_level})

    return random_bytes_response.data


def crc32c(data):
    """
    Calculates the CRC32C checksum of the provided data.

    Args:
        data: the bytes over which the checksum should be calculated.

    Returns:
        An int representing the CRC32C checksum of the provided bytes.
    """

    crc32c_fun = crcmod.predefined.mkPredefinedCrcFun('crc-32c')
    return crc32c_fun(six.ensure_binary(data))


if __name__ == '__main__':

    parser = argparse.ArgumentParser(
        description='Encrypt securely generated random bytes '
                    'using a symmetric key.')
    group1 = parser.add_argument_group("Crypto Key Self link")
    group2 = parser.add_argument_group("Crypto Key parameters")
    group3 = parser.add_argument_group("Service Account to be impersonated")

    group2.add_argument('--project_id', dest='project_id',
                        help='project_id (string): Google Cloud project ID.')
    group2.add_argument('--location_id', dest='location_id',
                        help='location_id (string): Cloud KMS location.')
    group2.add_argument('--key_ring_id', dest='key_ring_id',
                        help="key_ring_id (string): ID of the"
                        "Cloud KMS key ring.")
    group2.add_argument('--key_id', dest='key_id',
                        help='key_id (string): ID of the key to use.')

    group1.add_argument('--crypto_key_path', dest='crypto_key_path',
                        help='crypto_key_path (string): '
                        'Crypto key path to use. '
                        'Expected format: projects/PROJECT-ID/'
                        'locations/LOCATION-ID'
                        '/keyRings/KEY-RING-ID/cryptoKeys/KEY-ID')

    group3.add_argument('--service_account', dest='service_account',
                        help='service_account (string): '
                        'Service Account to be impersonated.')

    args = parser.parse_args()

    # Create the client.
    if args.service_account is not None:
        target_scopes = ['https://www.googleapis.com/auth/cloud-platform']

        source_credentials, project = google.auth.default(
            scopes=target_scopes)

        target_credentials = impersonated_credentials.Credentials(
            source_credentials=source_credentials,
            target_principal=args.service_account,
            target_scopes=target_scopes,
            lifetime=10)
        client = kms.KeyManagementServiceClient(credentials=target_credentials)
    else:
        client = kms.KeyManagementServiceClient()

    if args.crypto_key_path is not None:
        key_ring_args = client.parse_crypto_key_path(args.crypto_key_path)
        project_id = key_ring_args['project']
        location_id = key_ring_args['location']
        key_ring_id = key_ring_args['key_ring']
        key_id = key_ring_args['crypto_key']
    else:
        project_id = args.project_id
        location_id = args.location_id
        key_ring_id = args.key_ring_id
        key_id = args.key_id

    encrypt_response = encrypt_symmetric(project_id, location_id,
                                         key_ring_id, key_id, client)
    print(base64.b64encode(encrypt_response.ciphertext).decode("utf-8"))