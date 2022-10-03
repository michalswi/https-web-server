package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
)

var logger = log.New(os.Stdout, "web-server ", log.LstdFlags|log.Lshortfile|log.Ltime|log.LUTC)

func main() {
	port := getEnv("SERVER_PORT", "443")
	cert_path := "certs/"

	var c_file string
	var k_file string

	dir, _ := os.ReadDir(cert_path)
	if len(dir) == 2 {
		c_file = cert_path + "cert.crt"
		k_file = cert_path + "cert.key"
	} else {
		logger.Fatalln("cert and[or] key not provided or sth else!")
	}

	http.HandleFunc("/", home)
	http.HandleFunc("/hz", hz)
	http.HandleFunc("/ip", ip)
	logger.Println("Server is ready to handle requests at port", port)

	logger.Fatal(http.ListenAndServeTLS(":"+port, c_file, k_file, nil))
}

func home(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("how you doin'"))
	var x = map[string]string{}
	x["User-Agent"] = r.UserAgent()
	x["X-Forwarded-For"] = r.Header.Get("X-Forwarded-For")
	x["Remote-Addr"] = r.RemoteAddr
	b, _ := json.Marshal(x)
	logger.Printf("%s", b)
}

func hz(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("ok"))
}

func ip(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte(r.Header.Get("X-Forwarded-For")))
}

func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if len(value) == 0 {
		return defaultValue
	}
	return value
}
