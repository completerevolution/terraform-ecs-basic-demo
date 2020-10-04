# **Simple ECS Demo**

### _Requirements_

-   terraform >0.12
-   AWS access keys

### _Purpose_

These days it is the norm for organisations to make technical assessments on candidates by means of assignments. Much of these tasks overlap, in particular those regarding provisioning container orchestrators.

In time I will add more "scenarios" to Github (Kubernetes, Lambda, RDS, etc.)

### _Contents_

Contained in this repository is a basic AWS ECS architecture demonstrating the following:

-   100% Infrastructure-as-Code via Terraform
-   Varied use of modules, resources and templating (no point in reinventing the wheel...)
-   AWS ECS cluster with 2 nodes in private subnets
-   Nodes are in AutoScaling Group
-   Configuring both ALB and ECS to map port 80 (public to ALB) to 8080 (ALB to host) to 80 (host to container)
-   Nginx container has `s3:PutObject` rights via policy & role

### _Known limitations_ (in line with original assignment)

-   There is no KMS support
-   Local `tfstate` file
-   EC2 hosts lack SSH key
-   Dozens of others out of scope for the assignement

### _Instructions_

-   Checkout this repository
-   Ensure your AWS credentials are valid
-   Run `./bin/bootstrap.sh`
-   .... wait about 5-6 minutes (provisioning + health checks)...
-   Run `./bin/post-install.sh` to `curl` the default Nginx start page
