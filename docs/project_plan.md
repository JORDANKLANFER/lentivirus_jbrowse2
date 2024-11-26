# Contributing Guidelines

This document outlines how to contribute effectively and collaborate. 

---

## Workflow

### 1. Branching
- Always create a new branch for your work to avoid conflicts on the `main` branch.
- Name branches descriptively, using prefixes like `feature/`, `fix/`, or `docs/`


### 2. Pull Requests
- Once your feature or fix is complete, add, commit, push your branch to GitHub (YOUR BRANCH ONLY NOT MAIN)
- Open a pull request (PR) on GitHub
- Go to your repository on GitHub.
- Click Pull Requests in the top menu.
- Click New Pull Request
- Select your branch as the source and main as the target.
- Add a descriptive title and descrioption of what you did so we can all follow your work
- Assign at least one team member as a reviewer
- Each pull request must be reviewed and approved by at least one team member before merging
- If reviewers suggest changes, address them in additional commits on the same branch
- After approval, merge your branch into main using the "Squash and Merge" option (to keep the commit       history clean)
- After merging, delete your branch locally and remotely: 
     - git branch -d <branch-name>, git push origin --delete <branch-name>


### 3. Plugin Testing
- Run the JBrowse2 development server to test the plugin:
   - cd jbrowse-components/products/jbrowse-web
   - yarn start

### 4. Script Testing
- Use Python unit tests for installer scripts: pytest tests/test_installer.py 