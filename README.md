## Environment & Prerequisites

### Test Environment

The setup and validation were performed on a **K3s cluster using Calico** as the CNI plugin.

### Kubernetes Context

The machine executing the Ansible playbooks **must be configured with the correct Kubernetes context**.
All Ansible tasks rely on the active `kubectl` context to interact with the target cluster.

Ensure the context is set correctly before running any playbooks:

```bash
kubectl config current-context
```

### Requirements

The following tools are required on the machine running the automation:

* **Ansible**
* **curl**
## Running the Process

### Execution

To run the full setup process, execute the following command **from a machine that is configured with the correct Kubernetes context**:

```bash
./start.sh
```

The script relies on the active `kubectl` context to determine the target cluster.

---

### What the Script Does

After execution, the script performs the following actions automatically:

1. **Creates the required namespace(s)** in the Kubernetes cluster.
2. **Deploys the necessary Helm charts** using the appropriate `values.yaml` files.
3. **Applies network configurations**, including network policies between the relevant components.
4. **Imports the Kibana dashboard (graph)** into Kibana programmatically.

---

### Jenkins Pipeline

Once the deployment is complete:

1. Open the Jenkins UI.
2. Locate the **existing pipeline** that was created as part of the setup.
3. Click on the pipeline and **approve/enable the execution** when prompted.

   * This approval step is required before the pipeline can be executed for the first time.

---

### Kibana Integration (UI Requirement)

Before viewing the imported graph in Kibana:

* The relevant **integration must be added via the Kibana UI**.
* The integration **already exists and functions between the pods at the network level**,
  however, it **does not appear automatically in the Kibana UI**.
* At the moment
