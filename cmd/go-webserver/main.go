package main

import (
	"fmt"
	"github.com/gorilla/mux"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"os"
	"strconv"
	"strings"
	"sync"
	"time"
)

var products = newDefaultProducts()
var localIPs = getLocalIPs()
var locker sync.Mutex

func getLocalIPs() (ips []string) {
	addrs, err := net.InterfaceAddrs()
	if err != nil {
		return
	}

	for _, address := range addrs {
		if ipn, ok := address.(*net.IPNet); ok && ipn.IP.IsGlobalUnicast() {
			ips = append(ips, ipn.IP.String())
		}
	}

	return ips
}

func newDefaultProducts() int {
	p, _ := strconv.Atoi(os.Getenv("PRODUCTS"))
	if p == 0 {
		p = 5000
	}

	return p
}

func unmarshalTextResponse(resp *http.Response) (string, error) {
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	if resp.StatusCode == 200 {
		return string(body), nil
	} else {
		err = fmt.Errorf("unexpected response[%v]: %v", resp.StatusCode, string(body))
	}

	return "", err
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	resp := fmt.Sprintf("%s LocalIPs %v Host %s Remote %s", time.Now(), localIPs, r.Host, r.RemoteAddr)
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

func getProductsHandler(w http.ResponseWriter, r *http.Request) {
	locker.Lock()
	defer locker.Unlock()

	log.Printf("===>Preparing product for %s ...", r.RemoteAddr)

	if products > 0 {
		products--
		_, _ = fmt.Fprintf(w, "ok, got it!\n")
		return
	}

	_, _ = fmt.Fprintf(w, "sorry, sell out!\n")

	log.Printf("===>Success product for %s", r.RemoteAddr)
}

func resetProductsHandler(w http.ResponseWriter, r *http.Request) {
	locker.Lock()
	defer locker.Unlock()

	products = newDefaultProducts()
	_, _ = fmt.Fprintf(w, "ok\n")
}

func flashSaleHandler(w http.ResponseWriter, r *http.Request) {
	_ = r.ParseForm()
	link := r.Form.Get("link")
	users, _ := strconv.Atoi(r.Form.Get("users"))
	gotProducts := 0
	errorRequests := 0
	now := time.Now()

	var wg sync.WaitGroup
	for i := 0; i < users; i++ {
		wg.Add(1)

		go func() {
			defer wg.Done()

			log.Printf("+++ request product...")
			resp, err := http.Get(link)
			if err != nil {
				errorRequests += 1
				log.Printf("[error] flashSaleHandler: %v", err)
				return
			}

			result, err := unmarshalTextResponse(resp)
			if err != nil {
				errorRequests += 1
				log.Printf("[error] flashSaleHandler: %v, marshal: %v", result, err)

			} else if strings.HasPrefix(result, "ok") {
				log.Printf("+++ got product ok")
				gotProducts += 1
			} else {
				log.Printf("+++ request ok, but got product failed")
			}
		}()
	}

	wg.Wait()
	_, _ = fmt.Fprintf(w, "Worker: %v Users: %d GotProducts: %d ErrorRequests: %d Costs: %s\n", localIPs, users, gotProducts, errorRequests, time.Since(now))
}

func showProductsHandler(w http.ResponseWriter, r *http.Request) {
	locker.Lock()
	defer locker.Unlock()
	_, _ = fmt.Fprintf(w, "Products: %d\n", products)
}

func main() {
	r := mux.NewRouter()
	r.HandleFunc("/", homeHandler).Methods(http.MethodGet)
	r.HandleFunc("/forwarding/", forwardHandler).Methods(http.MethodGet)
	r.HandleFunc("/get-products/", getProductsHandler).Methods(http.MethodGet)
	r.HandleFunc("/products/", showProductsHandler).Methods(http.MethodGet)
	r.HandleFunc("/flash-sale/", flashSaleHandler).Methods(http.MethodGet)
	r.HandleFunc("/reset-products/", resetProductsHandler).Methods(http.MethodPost)

	log.Fatal(http.ListenAndServe(":8080", r))
}
