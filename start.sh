#!/bin/bash

ansible-playbook create_namespaces.yml
ansible-playbook apply_policies.yml
ansible-playbook install_helm.yml

NAMESPACE=elastic
SVC=kibana-kibana
SECRET=elasticsearch-master-credentials

KIBANA_IP="$(kubectl -n "$NAMESPACE" get svc "$SVC" -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
ELASTIC_USER="$(kubectl -n "$NAMESPACE" get secret "$SECRET" -o jsonpath='{.data.username}' | base64 --decode)"
ELASTIC_PASS="$(kubectl -n "$NAMESPACE" get secret "$SECRET" -o jsonpath='{.data.password}' | base64 --decode)"
[ -z "$KIBANA_IP" ] && echo "Kibana LB IP is empty" && exit 1

curl -sS -X POST "http://${KIBANA_IP}:5601/api/saved_objects/_import?overwrite=true" \
  -u "${ELASTIC_USER}:${ELASTIC_PASS}" \
  -H "kbn-xsrf: true" \
  -F file=@kibana-dashboard.ndjson
