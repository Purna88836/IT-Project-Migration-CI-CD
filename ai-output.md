Designing a GitHub-first CI/CD setup for MLOps on AWS with strong governance involves several components. Below is a comprehensive plan that addresses each of the deliverables:

### Branching Model Options

1. **Trunk-Based Development**
   - **Pros**: 
     - Encourages frequent integration, reducing merge conflicts.
     - Simplifies the CI/CD pipeline with fewer branches.
     - Suitable for teams practicing continuous delivery.
   - **Cons**:
     - Requires discipline to maintain code quality.
     - Can be challenging for larger teams without proper tooling.
   - **Guidance**: Ideal for smaller teams or those with a high release cadence.

2. **GitFlow**
   - **Pros**:
     - Clear separation of development, release, and hotfix branches.
     - Suitable for projects with scheduled releases.
   - **Cons**:
     - Can become complex with many branches.
     - Slower integration can lead to merge conflicts.
   - **Guidance**: Suitable for larger teams or projects with less frequent releases.

### Branch Protections

- **Main Branch**:
  - Require pull request reviews before merging.
  - Require status checks to pass before merging (lint, test, security scan, plan).
  - Enforce linear history.
  - Require signed commits.
  - Restrict who can push to the branch.

### CODEOWNERS Examples

```plaintext
# CODEOWNERS file
# Assign ownership to specific teams or individuals
/lambda-function/ @team-mlops
/docs/ @team-docs
```

- **Required Reviews**: At least one review from a CODEOWNER is required for changes in their respective areas.

### Required Status Checks and Environment Protection Rules

- **Status Checks**:
  - Linting
  - Unit and integration tests
  - Security scans
  - Infrastructure plan (e.g., Terraform plan)

- **Environment Protection Rules**:
  - **Dev**: Automatic deployments allowed.
  - **Stage**: Require manual approval for deployments.
  - **Prod**: Require multiple approvals and successful status checks.

### GitHub Actions: Reusable Workflows

- **Reusable Workflow Structure**:
  - **Data Checks**: Validate data quality and schema.
  - **Train**: Execute model training jobs.
  - **Eval**: Evaluate model performance.
  - **Register**: Register model in a model registry.
  - **Deploy**: Deploy model to AWS Lambda.

- **Features**:
  - Use matrices for testing across different environments.
  - Cache dependencies to speed up workflows.
  - Use artifacts to store and share build outputs.
  - Concurrency control to prevent overlapping runs.

### OIDC Role Trust Policy and IAM Policies

- **OIDC Role Trust Policy**:
  ```json
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::<AWS_ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "token.actions.githubusercontent.com:sub": "repo:<OWNER>/<REPO>:ref:refs/heads/main"
          }
        }
      }
    ]
  }
  ```

- **Least-Privilege IAM Policies**:
  - Allow actions specific to AWS Lambda for deployment.
  - Restrict access to only necessary resources (e.g., specific Lambda functions).

### Example PR Templates and Labels

- **PR Template**:
  ```markdown
  ## Description
  Describe the changes made in this PR.

  ## Checklist
  - [ ] Code is well-documented.
  - [ ] Tests have been added or updated.
  - [ ] Linting and tests pass.
  - [ ] Security scans are clear.
  - [ ] Rollout and rollback plans are documented.

  ## Risk Assessment
  - **Risk Level**: Low/Medium/High
  - **Rollout Plan**: Describe how this will be rolled out.
  - **Rollback Plan**: Describe how this can be rolled back.
  ```

- **Labels**:
  - `bug`, `feature`, `enhancement`, `documentation`, `urgent`

### Release/Versioning Strategy and Tags

- **Strategy**: Semantic Versioning (e.g., v1.0.0)
- **Tags**: Automatically tag releases using GitHub Actions.
- **Changelog Automation**: Use tools like `release-drafter` to automate changelog generation based on merged PRs.

This setup provides a robust framework for managing MLOps workflows on AWS using GitHub, ensuring strong governance and efficient CI/CD processes.