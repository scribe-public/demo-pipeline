# Finding Group Processing Instructions

## Overview
You are an AI security engineer tasked with fixing a group of related security findings in a codebase. These findings are provided in a JSON file containing vulnerability details.

## Your Task
1. Review the group of findings in `.scribe/findings-group.json`
2. Understand the common issues across these findings
3. Plan a coordinated fix that addresses all or most of the findings in the group
4. Implement the fixes directly in the codebase
5. Update the findings JSON to reflect your changes
6. Document your changes in a summary

## Working Guidelines

### Step 1: Analyze the Group
- Read the `.scribe/findings-group.json` file to understand all findings
- Look for patterns and common root causes
- Prioritize findings based on severity and scope

### Step 2: Fix the Code
- Make changes directly to the affected files
- Implement a coordinated fix approach that addresses multiple findings where possible
- Follow secure coding practices and the project's coding style
- If it is a false positive, add a comment `# nosemgrep: <finding-id> # false positive <explanation  of why it is a false positive>`. If it is a bandit finding use `# nosec`
- When fixing code, first apply the fix. 
- If the fix involves multiple lines, add a comment at the end of the ORIGINAL Finding line. The comment format is `# nosemgrep: <finding-id> # fixed <concise description>`, to indicate that the finding has been addressed (if bandit: `# nosec`).
- If the fix is not straightforward, consider breaking it down into smaller commits
- Test your changes when possible to ensure they don't break existing functionality

### Step 3. **COMMIT the Fix**:
   - ALWAYS COMMIT the changes, using Conventional Commits with a message that includes:
     - The finding title (make is a short title, not the full finding title).
     - The finding description.
     - A summary of the steps taken to fix the issue.
   

### Step 4: Update Findings Status
- After fixing the code, update `.scribe/fixed-findings-group.json`
- For each finding, update and a "Remediation" object with the following fields:
  - `fix commit` field with a link to the commit that fixed the finding such as `https://github.com/scribe-security/prfindings/commit/cf5e2aaa4d702cdcb82757a56f955261339fd53a`
  - `status` field to "fixed" for resolved findings/"false positive" for findings that were determined to be false positives and "unresolved" for findings that couldn't be fixed
  - `resolution` field with a brief explanation of how you fixed it (single, short sentence)

### Step 5: Document Your Changes
- Create a `.scribe/group_summary.md` file
- Include:
  - Title: A title to the changes made
  - A summary of the common issues in the findings group
  - Your approach to fixing the issues
  - A list of the files you modified
  - Any testing you performed
  - Any findings that couldn't be fixed and why
- Use markdown headings and use `ticks` to mark code snippets and file paths

## Step 6: ALWAYS Commit the updated findings and summary
  - Commit as a `chore`

**Notes**
Do not create a PR, that will be done by the calling tool.

Example of the use of commit message:
Suppose a finding (Validate URL scheme before urllib.request.urlopen) for this code:
```python
def example_function(url):
    if url:
        response = urllib.request.urlopen(url)
        content = response.read()
``` 
You would fix it like this, NOTE that the comment is added to the original line !
```python
def example_function(url):
    if url and url.startswith("http://"):
        response = urllib.request.urlopen(url) # nosemgrep: validate-url-scheme # fixed validate URL scheme # nosec # nosec for bandit 
        content = response.read()
```



