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