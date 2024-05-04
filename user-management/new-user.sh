#!/bin/bash
username=$1


ca_certs_path="./keys/ca"
if test -e $ca_certs_path
then
    echo "Cluster Certificates already Exist"
    echo "----------------------------------"
else
    echo "Extracting Cluster Certificates"

    # Extract certificate and key PEM strings
    certificate_pem=$(jq -r '.desiredState.certificatesBundle."kube-ca".certificatePEM' 'cluster.rkestate')
    key_pem=$(jq -r '.desiredState.certificatesBundle."kube-ca".keyPEM' 'cluster.rkestate')

    # Save certificate PEM
    mkdir -p $ca_certs_path

    echo -e "$certificate_pem" > $ca_certs_path/cert.pem

    # Save key PEM
    echo -e "$key_pem" > $ca_certs_path/key.pem

    echo "Certificate and key PEM strings extracted successfully!"
    echo "-------------------------------------------------------"
    echo "Convert CA Certs from PEM to CRT and KEY respectively"
    openssl x509 -in $ca_certs_path/cert.pem -out $ca_certs_path/cert.crt -outform der
    openssl rsa -in $ca_certs_path/key.pem -out $ca_certs_path/key.key -outform der
    echo "Certificate and key Files converted to DER format "
    echo "-------------------------------------------------------"
fi

user_path="./accounts/$username"
if test -e $user_path
then
    echo "User Credentials already Exist"
    echo "----------------------------------"
else
    echo "Creating Kubernetes Account for $username"
    mkdir -p $user_path
    echo "Generating User Key"
    openssl genrsa -out "$user_path/user.key" 2048

    echo "Generate Certificate Signing Request (CSR)"
    openssl req -new -key "$user_path/user.key" -out "$user_path/user.csr" -subj "/CN=$username/O=$username"

    echo "Signing CSR using Cluster Certificate Authority"
    sudo openssl x509 -req -in "$user_path/user.csr" -CA $ca_certs_path/cert.crt -CAkey $ca_certs_path/key.key -CAcreateserial -out "$user_path/user.crt" -days 365
    echo "User Certificate Created Successfully!"
    echo "--------------------------------------"
fi

echo "Register User Credentials with kubectl"

# Setup Dev Credentials
kubectl config set-credentials $username --client-certificate="$user_path/user.crt" --client-key="$user_path/user.key" --embed-certs --kubeconfig kube.config

# Setup local Context
kubectl config set-context "$username-context" --cluster=xeon --namespace=default --user=$username --kubeconfig kube.config
