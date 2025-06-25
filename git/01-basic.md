git init

git config --global user.name
git config --global user.email

git add <filename>
git add .

git commit -m '<msg>'
<!-- 지금 TIL은 remote add origin 할 필요 없음 -> clone 해왔기 때문 -->
git remote add origin <URL>

git push origin main

git status