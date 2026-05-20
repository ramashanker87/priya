Lab.md — Git Installation, Repository Setup & Branching Exercises
Git Fundamentals Lab
Lab Duration
2 Hours

Lab Objectives
By the end of this lab, learners will be able to:

Install Git
Configure Git user details
Create a local Git repository
Connect local repository with GitHub
Create and switch branches
Merge branches
Resolve basic Git workflow tasks
Prerequisites
Laptop/Desktop
Internet connection
GitHub account
VS Code or any text editor
Terminal / Command Prompt access
Part 1: Git Installation
Step 1: Check if Git is Installed
Open terminal and run:

git --version
Expected output:

git version 2.x.x
Step 2: Install Git
Windows
Download Git from:

https://git-scm.com/download/win
Install using default options.

macOS
brew install git
Ubuntu/Linux
sudo apt update
sudo apt install git -y
Step 3: Configure Git
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"
Verify configuration:

git config --list
Part 2: Repository Setup
Step 1: Create Project Folder
mkdir devops-git-lab
cd devops-git-lab
Step 2: Initialize Git Repository
git init
Expected output:

Initialized empty Git repository
Step 3: Create README File
echo "# DevOps Git Lab" > README.md
Check status:

git status
Step 4: Add File to Staging Area
git add README.md
Step 5: Commit File
git commit -m "Initial commit with README"
Part 3: GitHub Repository Setup
Step 1: Create Repository on GitHub
Create a new repository named:

devops-git-lab
Do not initialize with README.

Step 2: Connect Local Repo to GitHub
git remote add origin https://github.com/USERNAME/devops-git-lab.git
Verify remote:

git remote -v
Step 3: Push Code to GitHub
git branch -M main
git push -u origin main
Part 4: Branching Exercises
Exercise 1: Create a New Branch
git branch feature-login
Check branches:

git branch
Exercise 2: Switch to New Branch
git checkout feature-login
Or:

git switch feature-login
Exercise 3: Add File in Feature Branch
echo "Login feature added" > login.txt
git add login.txt
git commit -m "Added login feature"
Exercise 4: Switch Back to Main Branch
git checkout main
Or:

git switch main
Exercise 5: Merge Feature Branch into Main
git merge feature-login
Exercise 6: Push Changes to GitHub
git push origin main
Part 5: Additional Branch Practice
Create Another Branch
git checkout -b feature-payment
Create file:

echo "Payment feature added" > payment.txt
Commit changes:

git add payment.txt
git commit -m "Added payment feature"
Push branch:

git push origin feature-payment
Part 6: Git Log and History
View commit history:

git log
Short log:

git log --oneline
Graph view:

git log --oneline --graph --all
Part 7: Cleanup
Delete local branch:

git branch -d feature-login
Delete remote branch:

git push origin --delete feature-login
Lab Validation Checklist
Task	Status
Git installed	✅
Git configured	✅
Local repository created	✅
README committed	✅
GitHub repository connected	✅
Code pushed to GitHub	✅
Branch created	✅
Branch merged	✅
Commit history checked	✅
Common Git Commands
Command	Purpose
git init	Initialize repository
git status	Check file status
git add .	Stage files
git commit -m "message"	Commit changes
git branch	List branches
git checkout branch-name	Switch branch
git merge branch-name	Merge branch
git push	Push to remote
git pull	Pull latest changes
git log --oneline	View commit history
Lab Assignment
Create the following branches:

feature-homepage
feature-about-page
feature-contact-page
Each branch should contain one file:

homepage.html
about.html
contact.html
Each file should be committed and merged into the main branch.

Expected Final Repository Structure
devops-git-lab/
├── README.md
├── login.txt
├── payment.txt
├── homepage.html
├── about.html
└── contact.html
Summary
In this lab, you practiced:

Installing Git
Configuring Git
Creating a local repository
Connecting Git with GitHub
Creating branches
Switching branches
Merging branches
Pushing code to GitHub
