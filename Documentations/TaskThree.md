# Task 3: CI
## Design Proposal
![Alt text](cicd.png)

The diagram outlines the proposed CI system using Jenkins, the CI workflow, and the benefits it brings to ACME.

### CI System

**1. Proposed System:**
   - Jenkins is proposed as the CI system for its flexibility and integration capabilities.

**2. Key Considerations:**
   - Jenkins provides a centralized platform for managing CI workflows.
   - Can be extended with plugins to support various languages and build tools.

### CI Workflow

**1. Steps Automated by CI:**
   - **Build:**
     - Automatically triggered on code commits to the repository.
   - **Test:**
     - Runs unit tests and integration tests as part of the CI pipeline.
   - **Deploy to Staging:**
     - Automatic deployment to a staging environment for testing.
   - **Deploy to Production:**
     - Conditional deployment to production if tests pass in the staging environment.

**2. Problems CI Solves:**
   - **Consistent Builds:**
     - Ensures consistent and reproducible builds across environments.
   - **Automated Testing:**
     - Catches issues early through automated testing.
   - **Continuous Deployment:**
     - Facilitates continuous deployment, reducing manual intervention.

### Developer Workflow

**1. Workflow After CI Implementation:**
   - **Commit Code:**
     - Developers commit code to version control.
   - **CI Build:**
     - CI system automatically triggers builds on code commits.
   - **CI Test:**
     - CI system runs automated tests on the code.

### Changes in Release Process

**1. Changes Introduced:**
   - **Automated Deployments:**
     - Shifts from manual deployments to automated CI/CD pipelines.
   - **Faster Releases:**
     - Enables faster and more reliable releases with automated testing.

*Please Note: The diagram visually represents the proposed CI workflow, its benefits, and its integration into the developer workflow.*
