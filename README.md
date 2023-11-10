# Kruise-Argo

Welcome to the Kruise Argo repository, a space dedicated to improving the integration of custom resource health checks for specific workload resources from the OpenKruise project into ArgoCD. In this README, we'll provide an in-depth overview of our goals, the challenges we're addressing, and how you can contribute to this project.

## Purpose
Our primary objective is to enhance the capabilities of ArgoCD, a critical component in our cluster orchestration, by introducing custom health checks for various advanced workload resources. These resources, including CloneSet, StatefulSet, DaemonSet, BroadcastJob, AdvancedCronJob, and Rollout, are an integral part of the OpenKruise project. While ArgoCD excels at deploying and managing resources, it currently lacks built-in health status monitoring for these advanced workload resources.

## The Challenge
To illustrate the challenge, let's consider a typical scenario with a CloneSet Custom Resource (CR). This CR might have a status section like the following:

```
status:
  observedGeneration: 5
  replicas: 10
  updatedReadyReplicas: 6
  updatedAvailableReplicas: 6
```
ArgoCD, in its default configuration, would consider this application "healthy." However, in practice, we often encounter situations where such a state should be deemed "degraded" due to incomplete or problematic resource updates.

## Our Solution
To address this challenge, we've developed a solution using Lua scripts, which can detect and report the health status of custom workload resources. These Lua scripts, along with corresponding tests, are intended to be contributed back to the ArgoCD project. By doing so, we aim to empower ArgoCD with the ability to recognize and display the health status of advanced workload resources accurately.

## How to use the integration scripts with Argo-cd 

### Requirements : 

1. Kubernetes Cluster or Local minikube installed.

2. Argo-cd installed inside your cluster or local machine.

3. Kruise CRD's installed in your cluster or local machine. 

This README will guide you through the process of integrating Lua scripts with ArgoCD for managing workloads. Lua scripts can help ArgoCD monitor the health status of workloads effectively. In this example, we'll use the following CloneSet:

### Step 1: Install Openkruise as per the instructions given [here](https://openkruise.io/docs/installation/)

### Step 2: Setup the Argo-cd Pipeline or follow [this](https://openkruise.io/docs/best-practices/gitops-with-kruise/#tekton-pipeline--argo-cd) guide 

1. Change the directory to example folders by ```cd example/``` and ```kubectl apply -f argocd.yaml```.

2. You will have an argocd pipeline setup ready to apply and test artifacts.

3. Change the image version or replicas count inside openkruise_workloads/cloneset/cloneset.yaml.

4. Now you will see the changes reflected inside your kubernetes container.

### Step 3: Argo-cd CloneSet Health Check

### Manual way 

Configure CloneSet Argo-cd [Custom CRD Health Checks](https://argo-cd.readthedocs.io/en/stable/operator-manual/health/#custom-health-checks), With this configuration argo-cd is able to perform a healthy check of the CloneSet, such as whether the CloneSet is published and whether the Pods are ready, as follows：

```
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app.kubernetes.io/name: argocd-cm
    app.kubernetes.io/part-of: argocd
  name: argocd-cm
  namespace: argocd
data:
  resource.customizations.health.apps.kruise.io_CloneSet: |
  hs={ status = "Progressing", message = "Waiting for initialization" }

  if obj.status ~= nil then
        
      if obj.metadata.generation == obj.status.observedGeneration then

          if obj.spec.updateStrategy then
              if obj.spec.updateStrategy.paused == true then
                  hs.status = "Suspended"
                  hs.message = "Cloneset is paused"
                  return hs
              elseif obj.spec.updateStrategy.partition ~= 0 then
                  if obj.status.updatedReplicas >= obj.status.expectedUpdatedReplicas then
                    hs.status = "Suspended"
                    hs.message = "Cloneset needs manual intervention"
                    return hs
                 end
              end

          elseif obj.status.updatedAvailableReplicas == obj.status.replicas then
            hs.status = "Healthy"
            hs.message = "All Cloneset workloads are ready and updated"    
            return hs
        
          else
              if obj.status.updatedAvailableReplicas ~= obj.status.replicas then
                hs.status = "Degraded"
                hs.message = "Some replicas are not ready or available"
                return hs
              end
            end
        end
  end

return hs
```

### Automated way 

1. Change the directory to example folder by doing ```cd example/```

2. Now run the automation script update-argocd-configmap.sh by doing 
```bash update-argocd-configmap.sh```

3. This will edit the lua script and will add the neccessary configmap configurations inorder to check cloneset the workload health and display it.

### Step 4: You can view the health conditions of workload with argo-cd UI or CLI

![Preview](https://openkruise.io/assets/images/argo_sync_healthy-47754891eaf67731ab458189bd61ce7b.png)

## How to Contribute
We encourage you to be a part of this effort to enhance ArgoCD's capabilities. Here are the steps to get involved:

- Clone this repository: Begin by cloning this repository to your local environment:

```
git clone https://github.com/your-username/kruise-argo.git
cd kruise-argo
```

- Implement Health Checks: Develop health checks for the custom workload resources you are interested in. The existing health checks in the resource_customizations directory can serve as a guide. Remember, these checks are vital for identifying and reporting any degraded state of the resources.

- Create Tests: To ensure the accuracy and reliability of your health checks, write corresponding test cases. This step is crucial for maintaining the overall quality of the project.

- Submit a Pull Request (PR): Once you've implemented the health checks and tests, submit a pull request to this repository. In your PR description, provide comprehensive information about the health checks you've introduced, explaining their significance and how they improve ArgoCD's functionality. Don't forget to reference any related documentation or issues associated with your contribution.

## Additional Resources

- [OpenKruise GitHub Repository](https://github.com/openkruise/kruise): Learn more about OpenKruise, the source of advanced workload resources we're focusing on.

- [ArgoCD Documentation - Health Checks](https://argo-cd.readthedocs.io/en/stable/operator-manual/health/) : Explore ArgoCD's official documentation on health checks for a better understanding of the project's context.

We deeply appreciate your potential contribution to this project. By enhancing ArgoCD's health monitoring capabilities for advanced workload resources, you are making a significant impact on the reliability and stability of applications in production environments. Together, we can ensure the success of this endeavor.