#!/bin/bash

# Set the target ConfigMap name and namespace
CONFIGMAP_NAME="argocd-cm"
NAMESPACE="argocd"

# Define the new data to be added
NEW_DATA=$(cat <<EOL
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app.kubernetes.io/name: argocd-cm
    app.kubernetes.io/part-of: argocd
  name: argocd-cm
  namespace: argocd
data:
  resource.customizations: |
    apps.kruise.io/CloneSet:
      health.lua: |
        hs = {}
        -- if paused
        if obj.spec.updateStrategy.paused then
            hs.status = "Suspended"
            hs.message = "CloneSet is Suspended"
            return hs
        end

        -- check cloneSet status
        if obj.status ~= nil then
            if obj.status.observedGeneration < obj.metadata.generation then
                hs.status = "Progressing"
                hs.message = "Waiting for rollout to finish: observed cloneSet generation less than desired generation"
                return hs
            end

            if obj.status.updatedReplicas < obj.spec.replicas then
                hs.status = "Progressing"
                hs.message = "Waiting for rollout to finish: replicas haven't finished updating..."
                return hs
            end

            if obj.status.updatedReadyReplicas < obj.status.updatedReplicas then
                hs.status = "Progressing"
                hs.message = "Waiting for rollout to finish: replicas haven't finished updating..."
                return hs
            end

            hs.status = "Healthy"
            return hs
        end

        -- if status == nil
        hs.status = "Progressing"
        hs.message = "Waiting for cloneSet"
        return hs
EOL
)

# Apply the new ConfigMap data to update the existing ConfigMap
echo "$NEW_DATA" | kubectl apply -n "$NAMESPACE" -f -
