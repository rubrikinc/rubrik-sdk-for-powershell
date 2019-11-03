git config --global user.email "noreply@jaapbrasser.com"
git config --global user.name "jaapbrasser"
git branch devel
git checkout devel
git status
git branch
git add *
git commit -m "[skip ci] Adding changes from Azure DevOps Pipelines"
git push -u origin devel