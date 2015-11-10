#! /bin/sh

. ./config

get_fingerprint()
{
    local number="$1"
    echo $KEYIDS | awk "{print \$$number}"
}

secname="$1"

if [ -z "$secname" ] ; then
    echo "Usage:    quorum.sh secret-name" >&2
    echo
    exit 1
fi

# Pick a random secret
SECRET=$($RAND_CMD)

# Feed the secret in via stdin so it won't show up in ps/w
perl ./shares.pl $QUORUM $MEMBERS <<EOF | while read share ; do
$SECRET
EOF
    # Read which share number this is from the share itself
    number=$(echo $share | cut -d: -f2)
    # Grab the key id (FP:name) from the conf for this share number
    keyid=$(get_fingerprint $number)
    # Grab the fingerprint from the key id
    fingerprint=$(echo $keyid | cut -d: -f1)
    # Grab the login from the key id
    name="${secname}-$(echo $keyid | cut -d: -f2)"

    # Feed the secret in via stdin so it won't show up in ps/w
    $GNUPG $GNUPG_ARGS --encrypt --default-recipient $fingerprint \
        --output ${name}.asc <<EOF
$share
EOF

done

echo $SECRET

