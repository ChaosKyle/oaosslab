# Grafana OSS Training Lab Checklist

## **Scope and Timeline**
- [ ] **Timeline:** Complete lab environment in 1 week starting Monday.
- [ ] **Milestones:**  
  - [ ] **Day 1-2:**  
    - [ ] Deploy Grafana OSS Stack (Loki, Mimir, Tempo, Pyroscope, Alloy, and Grafana) using Docker Desktop and/or KinD.
    - [ ] Configure GitHub Actions CI/CD pipeline with GitOps for infrastructure deployment.
  - [ ] **Day 3:**  
    - [ ] Automate onboarding of data sources.
    - [ ] Validate dashboards as code for Logs, Metrics, Traces, and Profiles.
  - [ ] **Day 4:**  
    - [ ] Implement chaos engineering scenarios with LitmusChaos (latency injection, node failures, misconfigurations).
  - [ ] **Day 5:**  
    - [ ] Write Markdown documentation for the setup process.
  - [ ] **Day 6:**  
    - [ ] Create walkthrough videos for non-technical users.
  - [ ] **Day 7:**  
    - [ ] Conduct final review and test lab environment for ease of use.

---

## **Automation and CI/CD**
- [ ] Use **GitHub Actions** for CI/CD pipeline.
- [ ] Implement GitOps workflow for IaC automation using Terraform/OpenTofu.
- [ ] Automate onboarding of data sources with Alloy and validate connections.
- [ ] Deploy dashboards as code using the Grafana API.

---

## **Chaos Engineering**
- [ ] Use LitmusChaos for incident simulation.
- [ ] Implement scenarios to hit REDS metrics:
  - [ ] **Rate:** Requests per second, error rates.
  - [ ] **Errors:** Frequency and types of errors logged.
  - [ ] **Duration:** Response times and latencies.
  - [ ] **Saturation:** Resource usage and bottlenecks.
- [ ] Test resilience to:
  - [ ] Latency injection.
  - [ ] Node failures.
  - [ ] Misconfigurations.

---

## **Documentation and Walkthroughs**
- [ ] Write Markdown-based documentation in GitHub.
- [ ] Include:
  - [ ] Setup instructions for deploying Grafana OSS Stack.
  - [ ] Step-by-step guides for creating and managing dashboards.
  - [ ] Visual aids (diagrams, screenshots).
- [ ] Create beginner-friendly walkthrough videos targeted at non-technical users.

---

## **Lab Accessibility**
- [ ] Deploy lab environment locally using:
  - [ ] Docker Desktop.
  - [ ] KinD (Kubernetes in Docker).
- [ ] Provide optional instructions for cloud-based deployment.
- [ ] Include setup guides for both environments.

---

## **Metrics for Success**
- [ ] Successfully deploy the LGTMP stack.
- [ ] Integrate and monitor a demo app.
- [ ] Simulate incidents using chaos engineering.
- [ ] Detect and resolve issues using OSS Grafana tools.

---

### **Additional Notes**
- [ ] Ensure scalability and security in the onboarding process.
- [ ] Share public GitHub repository with:
  - [ ] Terraform scripts.
  - [ ] GitHub Action workflows.
  - [ ] Documentation.
- [ ] Test the full setup for reliability and usability.
