
## Description
Xkops is an integrated solution that combines widely-adopted open-source utilities to simplify Kubernetes management, emphasizing the enhancement of observability, reliability, security, and cost control in cluster operations which help users optimize the deployment and management of Kubernetes clusters.

## Features

## 📒 Getting Started
To install XkOps, please follow these steps

### 🔐 Secret Manager Setup
First, set up AWS secrets manager on your AWS account:

Refer to this guide for instructions on how to set up AWS secret manager OR
Use this script to automate the setup process.
### 📥 Install XkOps
Clone the repository and navigate to the cloned repo:
```bash
 git clone https://github.com/XgridInc/xkops.git && cd xkops
```
Update values.yaml file and input your specific value for each key.
Install XkOps using Helm:
```bash
 helm install xkops ./helm -f values.yml
```

After successful installation, obtain the link of the XkOps frontend service to access the dashboard:
```bash
 kubectl get svc -n xkops
```
Create an unclaimed volume in your cluster and delete it using the delete button on the dashboard. You can verify the volume deletion action both from the dashboard and the cluster.

## Troubleshooting
If you encounter issues while trying to connect to MongoDB, follow these troubleshooting steps to resolve common problems:

1. Check MongoDB Service Status
Ensure that the MongoDB service is running. You can check the status using the following command:

bash
Copy code
For Linux/Unix systems
```bash
sudo systemctl status mongod
```
For Windows systems
```bash
net start MongoDB
```
If the service is not running, start it using:
For Linux/Unix systems
```bash
sudo systemctl start mongod
```

# For Windows systems
```bash
net start MongoDB
```
2. Verify MongoDB Connection URI
Double-check the MongoDB connection URI in your application's configuration. Ensure it follows the correct format:
```bash
mongodb://<username>:<password>@<host>:<port>/<database>
```
Example:
```bash
mongodb://myUser:myPassword@localhost:27017/myDatabase
```

3. Network Configuration
Ensure that your firewall or network settings are not blocking the MongoDB port (default is 27017). You may need to allow connections on this port.

4. Authentication
If authentication is enabled, verify that the provided username and password are correct. You can test the connection using the MongoDB shell:
```bash
mongo -u <username> -p <password> --authenticationDatabase <database> <host>:<port>
```

5. Logs and Error Messages
Check the MongoDB log files for error messages. The default log file location is:

**Linux/Unix:** /var/log/mongodb/mongod.log 

**Windows:** C:\Program Files\MongoDB\Server\<version>\log\mongod.log 

Review the logs for any errors or warnings that can provide more insight into the issue.

6. Client Compatibility
Ensure that the MongoDB client driver version you are using is compatible with your MongoDB server version.

7. Database Permissions
Verify that the user has the necessary permissions to access the database. You can check and grant permissions using the following commands in the MongoDB shell:

javascript
```bash
use <database>
db.createUser({
  user: "<username>",
  pwd: "<password>",
  roles: [ { role: "readWrite", db: "<database>" } ]
})
```

8. Connection Timeout
If the connection is timing out, try increasing the timeout settings in your application's MongoDB client configuration.

9. Replica Set Configuration
If you are connecting to a replica set, ensure that your connection string includes the replica set name and that the replica set is properly configured.

```bash
mongodb://<username>:<password>@<host1>:<port1>,<host2>:<port2>,<host3>:<port3>/?replicaSet=<replicaSetName>
```
Following these steps, you should be able to troubleshoot and resolve most MongoDB connection issues. If you continue to experience problems, consult the [MongoDB documentation](https://www.mongodb.com/docs/) or seek help from the community.

### 🤝 How to contribute

We invite you to contribute to XkOps, which is a community driven project. If you plan on contributing code, kindly go through our [contribution guide](https://github.com/XgridInc/xkops/blob/master/CONTRIBUTING.md).

To report a bug or request a feature, you can submit a [GitHub issue](https://github.com/XgridInc/xkops/issues).
For real-time discussions and immediate assistance, please join our [Slack channel](https://xkops.slack.com/join/shared_invite/zt-1u8xzjvvq-B52TJ2XE861v3KDvpA9UVg#/shared-invite/error).


## 🧾 License
XkOps is licensed under Apache License, Version 2.0. See [LICENSE.md](https://github.com/XgridInc/xkops/blob/master/LICENSE) for more information



