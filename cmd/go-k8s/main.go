package main

import (
	"context"
	"os"
	"time"

	log "github.com/sirupsen/logrus"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
)

func main() {
	log.Infof("Args: %v", os.Args)

	// creates the in-cluster config
	config, err := rest.InClusterConfig()
	if err != nil {
		panic(err.Error())
	}

	clientSet, err := kubernetes.NewForConfig(config)
	if err != nil {
		panic(err.Error())
	}

	for {
		// get pods in all the namespaces by omitting namespace
		// Or specify namespace to get pods in particular namespace
		pods, err := clientSet.CoreV1().Pods("default").List(context.TODO(), metav1.ListOptions{})
		if err != nil {
			log.Errorf("cannot list pods in namespace default: %v", err)
		} else {
			log.Infof("There are %d pods in namespace default\n", len(pods.Items))
		}

		time.Sleep(10 * time.Second)
	}
}
