# Static Webserver Usage

How to configure:

    ```bash
    kustomize build | kubectl apply -f -
    kubectl -n static-webserver get pods
    ```

Restart:

    ```bash
    kubectl delete pods --all -n static-webserver
    ```

Remove:

    ```bash
    kubectl delete ns static-webserver
    ```
