package main

import (
	"os"

	"github.com/DataDog/kube-sync/pkg/command"
	"github.com/golang/glog"
)

func main() {
	cmd, exitCode := command.NewCommand()
	err := cmd.Execute()
	if err != nil {
		os.Exit(1)
	}
	if *exitCode != 0 {
		glog.Errorf("Exiting on error: %d", *exitCode)
		os.Exit(*exitCode)
	}
}
