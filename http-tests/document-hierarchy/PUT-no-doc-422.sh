#!/usr/bin/env bash
set -euo pipefail

initialize_dataset "$END_USER_BASE_URL" "$TMP_END_USER_DATASET" "$END_USER_ENDPOINT_URL"
initialize_dataset "$ADMIN_BASE_URL" "$TMP_ADMIN_DATASET" "$ADMIN_ENDPOINT_URL"
purge_cache "$END_USER_VARNISH_SERVICE"
purge_cache "$ADMIN_VARNISH_SERVICE"
purge_cache "$FRONTEND_VARNISH_SERVICE"

pushd . > /dev/null && cd "$SCRIPT_ROOT/admin/acl"

# add an explicit read/write authorization for the parent since the child document will inherit it

./create-authorization.sh \
  -b "$ADMIN_BASE_URL" \
  -f "$OWNER_CERT_FILE" \
  -p "$OWNER_CERT_PWD" \
  --label "Write base" \
  --agent "$AGENT_URI" \
  --to "$END_USER_BASE_URL" \
  --read \
  --write

popd > /dev/null

# replace the graph (note that the request URI ends with a slash but is not present in the request body)

item="${END_USER_BASE_URL}slash/"

(
curl -k -w "%{http_code}\n" -o /dev/null -s \
  -E "$AGENT_CERT_FILE":"$AGENT_CERT_PWD" \
  -X PUT \
  -H "Accept: application/n-triples" \
  -H "Content-Type: application/n-triples" \
  --data-binary @- \
  "$item" <<EOF
<http://example.com/> <http://example.com/default-predicate> "named object PUT" .
EOF
) \
| grep -q "$STATUS_UNPROCESSABLE_ENTITY"