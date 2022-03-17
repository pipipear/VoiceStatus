package main

import (
	"encoding/json"
	"fmt"
	"os"
	"os/signal"
	"regexp"
	"sort"
	"syscall"
	"time"

	"github.com/bwmarrin/discordgo"
	"github.com/gin-gonic/gin"
	"github.com/spf13/viper"
	"gopkg.in/olahol/melody.v1"
)

var m = melody.New()
var info map[string]interface{}
var rl int64 = time.Now().Unix()

type CustomVoiceState struct {
	UserID        string `json:"user_id"`
	Avatar        string `json:"avatar"`
	Nick          string `json:"nick"`
	Username      string `json:"username"`
	Discriminator string `json:"discriminator"`
	Suppress      bool   `json:"suppress"`
	SelfMute      bool   `json:"self_mute"`
	SelfDeaf      bool   `json:"self_deaf"`
	Mute          bool   `json:"mute"`
	Deaf          bool   `json:"deaf"`
}

func main() {
	gin.SetMode(gin.ReleaseMode)
	r := gin.Default()
	viper.SetConfigFile(os.ExpandEnv("$HOME/.config/VoiceStatus.json"))
	viper.SetConfigType("json")

	verr := viper.ReadInConfig()
	if verr != nil {
		fmt.Println("fatal error config file: default \n", verr)
		os.Exit(1)
	}

	m.Upgrader.CheckOrigin = nil // prevent web pages from connecting
	info = map[string]interface{}{
		"discordAPI":    "disconnected",
		"voiceChannels": nil,
	}

	r.SetTrustedProxies([]string{"localhost"})

	r.GET("/ws", func(c *gin.Context) {
		m.HandleRequest(c.Writer, c.Request)
	})

	m.HandleConnect(func(s *melody.Session) {
		jsonInfo, _ := json.Marshal(info)
		s.Write([]byte(jsonInfo))
	})

	go r.Run(":" + viper.GetString("PORT"))

	TOKEN := viper.GetString("TOKEN")
	discord, dgerr := discordgo.New("Bot " + TOKEN)
	if dgerr != nil {
		fmt.Println(dgerr)
		info["discordAPI"] = "error"
		return
	}

	discord.AddHandler(voiceStateUpdate)
	discord.AddHandler(guildMemberUpdate)
	discord.AddHandler(connect)
	discord.AddHandler(disconnect)
	discord.Identify.Intents = discordgo.IntentsAll

	dgerr = discord.Open()
	if dgerr != nil {
		fmt.Println(dgerr)
		info["discordAPI"] = "error"
		return
	}

	fmt.Println("Logged in to Discord")
	sc := make(chan os.Signal, 1)
	signal.Notify(sc, syscall.SIGINT, syscall.SIGTERM, os.Interrupt)
	<-sc
	fmt.Println("\nClosing connection with Discord")
	discord.Close()
}

func voiceStateUpdate(s *discordgo.Session, m *discordgo.VoiceStateUpdate) {
	updateInfo(s)
}

func guildMemberUpdate(s *discordgo.Session, m *discordgo.GuildMemberUpdate) {
	now := time.Now().Unix()
	if now-rl > 10 {
		rl = now
		for _, Guild := range s.State.Guilds {
			for _, VoiceState := range Guild.VoiceStates {
				if m.User.ID == VoiceState.UserID {
					updateInfo(s)
					return
				}
			}
		}
	}
}

func connect(s *discordgo.Session, m *discordgo.Connect) {
	setInfo("discordAPI", "connected")
	time.Sleep(50 * time.Millisecond)
	for i := 0; i < 3; i++ {
		updateInfo(s)
		time.Sleep(1 * time.Second)
	}
}

func disconnect(s *discordgo.Session, m *discordgo.Disconnect) {
	setInfo("discordAPI", "disconnected")
}

func updateInfo(s *discordgo.Session) {
	Channels := make(map[string]map[string][]*CustomVoiceState)
	for _, Guild := range s.State.Guilds {
		Channels[Guild.ID] = make(map[string][]*CustomVoiceState)
		sort.Slice(Guild.Channels, func(i, j int) bool {
			return Guild.Channels[i].Position < Guild.Channels[j].Position
		})

		count := 0
		for _, Channel := range Guild.Channels {
			if len(Channel.ParentID) == 0 && Channel.Type == discordgo.ChannelTypeGuildVoice {
				channelUsers := processVC(Guild, Channel)
				orderHack := "=" + string(rune(count)) + "=" + Channel.ID // hack to force positional sort order
				Channels[Guild.ID][orderHack] = make([]*CustomVoiceState, len(channelUsers))
				Channels[Guild.ID][orderHack] = channelUsers
				count++
			}
		}

		// This recursion can likely be improved
		for _, Category := range Guild.Channels {
			if Category.Type == discordgo.ChannelTypeGuildCategory {
				for _, Channel := range Guild.Channels {
					if Channel.ParentID == Category.ID && Channel.Type == discordgo.ChannelTypeGuildVoice {
						channelUsers := processVC(Guild, Channel)
						orderHack := "=" + string(rune(count)) + "=" + Channel.ID
						Channels[Guild.ID][orderHack] = make([]*CustomVoiceState, len(channelUsers))
						Channels[Guild.ID][orderHack] = channelUsers
						count++
					}
				}
			}
		}
	}

	// remove sort order hack
	jsonChannels, _ := json.MarshalIndent(Channels, "", "  ")
	orderHackRegexp := regexp.MustCompile(`    "=.*=`)
	fixedJsonChannels := orderHackRegexp.ReplaceAllString(string(jsonChannels), `    "`)

	fmt.Println(fixedJsonChannels)
	setInfo("voiceChannels", fixedJsonChannels)
}

func processVC(gd *discordgo.Guild, vc *discordgo.Channel) []*CustomVoiceState {
	vs := gd.VoiceStates
	gm := gd.Members
	var channelUsers []*CustomVoiceState
	for _, VState := range vs {
		if VState.ChannelID == vc.ID {
			fmt.Println(VState)
			for _, member := range gm {
				if member.User.ID == VState.UserID {
					CustomVState := &CustomVoiceState{
						UserID:        VState.UserID,
						Avatar:        member.User.AvatarURL("128"),
						Nick:          member.Nick,
						Username:      member.User.Username,
						Discriminator: member.User.Discriminator,
						Suppress:      VState.Suppress,
						SelfMute:      VState.SelfMute,
						SelfDeaf:      VState.SelfDeaf,
						Mute:          VState.Mute,
						Deaf:          VState.Deaf,
					}
					channelUsers = append(channelUsers, CustomVState)
					break // without this, users are listed twice
				}
			}
		}
	}
	return channelUsers
}

func setInfo(k string, v interface{}) {
	info[k] = v
	jsonInfo, _ := json.Marshal(info)
	m.Broadcast([]byte(jsonInfo))
}
