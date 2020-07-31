# Git merging steps
# Checkout
git checkout master

# Pull any new updates
git pull

# Branch
git checkout $branch

git rebase master

#If you encounter a merge issue, open your merge tool:
#https://www.intertech.com/Blog/git-mergetool-specifying-which-merge-tool-git-should-use/

git mergetool
#Fix merge issues & Continue with rebase:
git rebase --continue


#If you encounter more merge issues, repeat above

#f you make a mistake while merging, abort the merge to discard all changes 
git rebase --abort


#When you have nothing left to merge, push changes to the branch
git push -f




git add -p
#Rename a branch
git branch -m oldName newName
