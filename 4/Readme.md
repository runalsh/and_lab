Bot for telegram to get information about course progress

Prereq:
1) install GoLang from https://go.dev/dl/

2) add some necessary api
go get github.com/Syfaro/telegram-bot-api

How to run
1) go run bot2.go -tt MY_SECRET_TOKEN
2) compiled version for Linux , dont forget about chmod +x bot2_linux
  ./bot2_linux-tt MY_SECRET_TOKEN

where is MY_SECRET_TOKEN token to access the HTTP API from @BotFather

Usage Bot:
Type /git to receive course repo link
Type /tasks to get list of complited homeworks
Type /taskX where is X - number of homework to get link

Test bot https://t.me/annvjskgvnkd_bot
