gitlog=$(git log --oneline -1) 
regex="\[skip ci\]"
if [[ $gitlog =~ $regex ]]
then
  exit 1
fi