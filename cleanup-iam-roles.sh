#!/bin/bash

set -e

echo "Fetching all IAM roles..."
roles=$(aws iam list-roles --query 'Roles[].RoleName' --output text)

for role in $roles; do
  echo "Processing role: $role"

  # List attached managed policies
  attached_policies=$(aws iam list-attached-role-policies --role-name "$role" --query 'AttachedPolicies[].PolicyArn' --output text)

  # Detach all attached managed policies
  if [ -n "$attached_policies" ]; then
    echo " Detaching attached managed policies..."
    for policy_arn in $attached_policies; do
      echo "  Detaching $policy_arn from $role"
      aws iam detach-role-policy --role-name "$role" --policy-arn "$policy_arn"
    done
  else
    echo " No attached managed policies."
  fi

  # List inline policies
  inline_policies=$(aws iam list-role-policies --role-name "$role" --query 'PolicyNames' --output text)
  if [ -n "$inline_policies" ]; then
    echo " Found inline policies:"
    for inline_policy in $inline_policies; do
      echo "  Deleting inline policy $inline_policy"
      aws iam delete-role-policy --role-name "$role" --policy-name "$inline_policy"
    done
  fi

  # Check if role is attached to instance profiles
  instance_profiles=$(aws iam list-instance-profiles-for-role --role-name "$role" --query 'InstanceProfiles[].InstanceProfileName' --output text)
  if [ -n "$instance_profiles" ]; then
    echo " Role is associated with instance profiles:"
    for ip in $instance_profiles; do
      echo "  Removing role $role from instance profile $ip"
      aws iam remove-role-from-instance-profile --instance-profile-name "$ip" --role-name "$role"
    done
  fi

  # Now try deleting the role
  echo " Attempting to delete role: $role"
  if aws iam delete-role --role-name "$role"; then
    echo " Role $role deleted successfully."
  else
    echo " Could not delete role $role. Please check manually."
  fi

  echo "------------------------------"
done

echo "Cleanup script completed."
