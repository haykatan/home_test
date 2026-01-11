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
3. **Installs Harbor via Helm**, which is used as a container registry for storing and managing build artifacts.
4. **Applies network configurations**, including network policies between the relevant components.
5. **Imports the Kibana dashboard (graph)** into Kibana programmatically.

---

### Jenkins Pipeline

Once the deployment is complete:

1. Open the Jenkins UI.
2. Locate the **existing pipeline** that was created as part of the setup.
3. Click on the pipeline and **approve/enable the execution** when prompted.

   * This approval step is required before the pipeline can be executed for the first time.
4. The pipeline builds the artifacts and **pushes the resulting images to Harbor**.

---

### Kibana Integration (UI Requirement)

Before viewing the imported graph in Kibana:

* The relevant **integration must be added via the Kibana UI**.
* The integration **already exists and functions between the pods at the network level**,
  however, it **does not appear automatically in the Kibana UI**.
* At the moment, no automated method was found to register this integration in the UI,
  therefore this step must be completed manually.

Once the integration is added in the UI, the imported dashboard and graphs will be visible and fully functional.
