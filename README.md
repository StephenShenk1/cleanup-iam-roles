# cleanup-iam-roles

Bash script that:

Lists all IAM roles

Checks if they have attached managed policies

Detaches all attached managed policies

Deletes the role if no inline policies or instance profiles remain

This will safely clean up roles with attached managed policies.

**How to use:**

Save this to a file, as "cleanup-iam-roles.sh."

#**Give it execute permissions:**
chmod +x cleanup-iam-roles.sh

#**Run it:**
./cleanup-iam-roles.sh

**N.B: ** It will safely clean up all roles that have attached policies or inline policies or instance profiles.

