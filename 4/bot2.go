package main


import (
	"encoding/json"
	"fmt"
	"net/http"
	re "regexp"
	"flag"
	"strconv"
	"github.com/Syfaro/telegram-bot-api"
	"log"
	"os"
	"io/ioutil"

)

var (
	// токен
	telegramBotToken string
)

func init() {
	// аргумент
	flag.StringVar(&telegramBotToken, "tt", "", "Telegram Bot Token")
	flag.Parse()

	// без него не запускаемся
	if telegramBotToken == "" {
		log.Print("-tt is required")
		os.Exit(1)
	}
}

func getTasks() []string {
	taskTree := fmt.Sprintf("https://api.github.com/repos/runalsh/and_lab/git/trees/lab")
	resp, err := http.Get(taskTree)
	if err != nil {
		log.Fatalln(err)
	}
	//читаем json
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Fatalln(err)
	}
	sb := string(body)
	//парсинг результатов с определенной картой
	// можно брать json через https://api.github.com/repos/runalsh/and_lab/contents?ref=lab там всё сразу `json:"name"` `json:"html_url"`
	var result map[string][]interface{}
	var resq []string
	//демаршалируем 
	json.Unmarshal([]byte(sb), &result)
	for _, v := range result["tree"] {
		entry := v.(map[string]interface{})
		if entry["type"] == "tree" {
			resq = append(resq, fmt.Sprintf("%v", entry["path"]))
		}
	}
	return resq
}


func main() {
	// новый инстанс бота
	bot, err := tgbotapi.NewBotAPI(telegramBotToken)
	if err != nil {
		log.Panic(err)
	}

	bot.Debug = true
	
	log.Printf("Authorized on account %s", bot.Self.UserName)

	// для получения апдейтов
	u := tgbotapi.NewUpdate(0)
	u.Timeout = 60

	// используя конфиг u создаем канал
	updates := bot.GetUpdatesChan(u)

	// в канал updates прилетают  Update
	// 
	for update := range updates {
		// универсальный ответ 
		reply := "Type /help to see a tip"
		if update.Message == nil {
			continue
		}

		// логируем от кого какое сообщение пришло
		log.Printf("[%s] %s", update.Message.From.UserName, update.Message.Text)

		// свитч на обработку комманд
		// комманда - сообщение, начинающееся с "/"
		switch update.Message.Command() {
		case "start":
			reply = "Hello. Im bot from @runalsh or @ilnursh for course"
		case "help":
			reply = "Type /git to receive course repo link\nType /tasks to get list of complited homeworks\nType /taskX where is X - number of homework to get link"
		case "git":
			reply = "Enjoy (or not) https://github.com/runalsh/and_lab/tree/lab/"
		case "tasks":
			var rString string = ""
			tasks := getTasks()
			for i, t := range tasks {
				task := fmt.Sprintf("%d - /task%s ", i+1, t)
				rString = rString + task + "\n"
			}
			msg := tgbotapi.NewMessage(update.Message.Chat.ID, rString)
			bot.Send(msg)
		case "task":
				taskArgs := update.Message.CommandArguments()
				tasks := getTasks()
				inputNum, err := strconv.Atoi(taskArgs)
				if err != nil {
					// handle error
					msg := tgbotapi.NewMessage(update.Message.Chat.ID, "Got error task number: "+taskArgs)
					bot.Send(msg)
				}
				if inputNum > 0 {
					taskUrl := fmt.Sprintf("https://github.com/runalsh/and_lab/tree/lab/%s", tasks[inputNum-1])
					msg := tgbotapi.NewMessage(update.Message.Chat.ID, taskUrl)
					bot.Send(msg)
				} else {
					msg := tgbotapi.NewMessage(update.Message.Chat.ID, "Got error task number: "+taskArgs)
					bot.Send(msg)
			}
		default:
				taskArgs := update.Message.Text
				pattern := re.MustCompile("/task([1-6]+)")
				if pattern.MatchString(taskArgs) {
					inputNum := pattern.FindStringSubmatch(taskArgs)[1]
					taskUrl := fmt.Sprintf("https://github.com/runalsh/and_lab/tree/lab/%s", inputNum)
					msg := tgbotapi.NewMessage(update.Message.Chat.ID, taskUrl) 
					bot.Send(msg)
					//reply = "inputNum="+inputNum
				} else {
					msg := tgbotapi.NewMessage(update.Message.Chat.ID, "Got error task number: "+taskArgs)
					bot.Send(msg)
			}	 	
						
		}
 		// создаем ответное сообщение
		msg := tgbotapi.NewMessage(update.Message.Chat.ID, reply)
		// отправляем
		bot.Send(msg)
	}
}


























