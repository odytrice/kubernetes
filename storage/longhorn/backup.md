# Longhorn Backup

[![Watch the video](https://i.ytimg.com/vi/qgDy07Dgm8Q/sddefault.jpg)](https://youtu.be/qgDy07Dgm8Q)

## Prerequisites

- Create S3 Bucket
- Create IAM Role
- Generate IAM CLI Access Keys

## Create AWS Secret

```bash
kubectl create secret generic aws-secret --from-literal="AWS_ACCESS_KEY_ID=XXXXXXXXXX" --from-literal="AWS_SECRET_ACCESS_KEY=XXXXXXXXXX" -n longhorn-system
```

## Configure Secret in Longhorn

- Port Forward Longhorn UI Service i.e. 8000 -> 8000
- Navigate to http://longhorn:8000
- Go to Settings
- Change "Backup Target" to "s3://bucketname@region/path"
- Change "Backup Target Credential Secret" to "aws-secret"