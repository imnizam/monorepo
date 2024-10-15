SCRIPTPATH=$(dirname "$0")
export FOLDER="${SCRIPTPATH}/ca"
mkdir -p ${FOLDER}
cat >"${FOLDER}/ca.cnf" <<EOF
# all the fields in this CNF are just example, Client should follow its own PKI practice to configue it properly
[ req ]
encrypt_key        = no
utf8               = yes
default_bits       = 4096
default_md         = sha256
prompt             = no
distinguished_name = req_distinguished_name
req_extensions     = req_ext
x509_extensions    = req_ext
[ req_distinguished_name ]
countryName         = US
stateOrProvinceName = CA
organizationName    = Example
commonName          = SelfSignedRootCA
[ req_ext ]
subjectKeyIdentifier = hash
basicConstraints     = critical, CA:true
keyUsage             = critical, digitalSignature, nonRepudiation, keyEncipherment, keyCertSign
EOF

openssl genrsa \
  -out "${FOLDER}/ca.key" \
  4096

openssl req \
  -new \
  -key "${FOLDER}/ca.key" \
  -config "${FOLDER}/ca.cnf" \
  -out "${FOLDER}/ca.csr"

openssl x509 \
  -req \
  -days 365 \
  -signkey "${FOLDER}/ca.key" \
  -extensions req_ext \
  -extfile "${FOLDER}/ca.cnf" \
  -in "${FOLDER}/ca.csr" \
  -out "${FOLDER}/ca.crt"
