#!/bin/bash
# Dumps open search indices status.

#### Variables ####
# NAMESPACE = Exact namespace where OpenSearch runs within k8s.

echo "==== OpenSearch Indices for Namespace ${NAMESPACE}"

OS_USERNAME=$(kubectl -n ${NAMESPACE} get secret sas-opendistro-sasadmin-secret -o jsonpath="{.data.username}"| base64 --decode)
OS_PASSWORD=$(kubectl -n ${NAMESPACE} get secret sas-opendistro-sasadmin-secret -o jsonpath="{.data.password}"| base64 --decode)

kubectl -n ${NAMESPACE} exec pod/sas-opendistro-opensearch-data-0 --stdin --tty -- /bin/bash -c "curl --insecure https://localhost:9200/_cat/indices?s=index -u $OS_USERNAME:$OS_PASSWORD"

