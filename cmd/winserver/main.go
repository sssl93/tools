package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"time"
)

func unmarshalTextResponse(resp *http.Response) (string, error) {
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	if resp.StatusCode == 200 {
		return string(body), nil
	} else {
		err = fmt.Errorf("unexpected response[%v]: %v", resp.StatusCode, body)
	}

	return "", err
}

func rootHandler(w http.ResponseWriter, r *http.Request) {
	resp := fmt.Sprintf("%s From %s", time.Now(), r.Host)
	fmt.Println(resp)
	_, _ = fmt.Fprintf(w, resp)
}

func forwardHandler(w http.ResponseWriter, r *http.Request) {
	_ = r.ParseForm()
	url := r.Form.Get("url")
	resp, err := http.Get(url)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		log.Printf("GET ERROR: [%v]%v body: %+v InternalServerError: %v", "GET", url, r.Body, err)
		_, _ = fmt.Fprintf(w, err.Error())
		return
	}

	result, err := unmarshalTextResponse(resp)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		log.Printf("Unmarshal ERROR: [%v]%v body: %+v InternalServerError: %v", "GET", url, r.Body, err)
		_, _ = fmt.Fprintf(w, err.Error())
		return
	}

	_, _ = fmt.Fprintf(w, result)
}

func main() {
	http.HandleFunc("/", rootHandler)
	http.HandleFunc("/forward/", forwardHandler)
	log.Fatal(http.ListenAndServe(":8080", nil))
}
