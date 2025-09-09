Okay.

Now let’s create the **service for RabbitMQ**.

So open the `rmq-service.yaml` file.

I’ll copy everything from the **memcache service file** because the structure is the same. Then we’ll just modify the names, labels, and ports.

- **Service Name** → This matters because our application properties file expects a service name. In the `application.properties`, the RabbitMQ service name is given as `wipro-rmq`. So that’s what we must use in the service definition.

- **Selector** → It should match the label we used in the RabbitMQ deployment (i.e., `app: wipro-rmq`).

- **Port Number** → RabbitMQ listens on port `5672`. So the service’s port will be `5672`.

- **Target Port** → In the RabbitMQ deployment, we gave the container port `5672` with a name `wipro-rmq-port`. So in the service, we can use that port name as the `targetPort`.

So the RabbitMQ service file will look like this:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: wipro-rmq
spec:
  selector:
    app: wipro-rmq
  ports:
    - port: 5672
      targetPort: wipro-rmq-port
  type: ClusterIP
```

Now we’re done with the **RabbitMQ deployment and service**.

✅ Recap so far:

- **Secrets** (DB & RabbitMQ passwords) ✅
- **PVC** (for MySQL) ✅
- **MySQL Deployment & Service** ✅
- **Memcache Deployment & Service** ✅
- **RabbitMQ Deployment & Service** ✅

Next up → we’ll move on to **Tomcat App (Wipro App)** deployment and service, and finally the **Ingress** for external access.

