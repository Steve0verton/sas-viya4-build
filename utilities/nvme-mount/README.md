# NVMe Mount Usage

How to configure:

    ```bash
    kustomize build | kubectl apply -f -
    kubectl -n nvme-mount get pods
    ```

Restart:

    ```bash
    kubectl delete pods --all -n nvme-mount
    ```

Remove:

    ```bash
    kubectl delete ns nvme-mount
    ```
