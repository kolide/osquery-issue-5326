package main

import (
	"bytes"
	"context"
	"encoding/json"
	"flag"
	"log"
	"os"
	"time"

	osquery "github.com/kolide/osquery-go"
	"github.com/kolide/osquery-go/plugin/logger"
	"github.com/kolide/osquery-go/plugin/table"
)

func main() {
	var (
		flSocketPath = flag.String("socket", "", "")
		flTimeout    = flag.Int("timeout", 0, "")
		_            = flag.Int("interval", 0, "")
		_            = flag.Bool("verbose", false, "")
	)
	flag.Parse()

	server, err := osquery.NewExtensionManagerServer(
		"com.kolide.issue_5326",
		*flSocketPath,
		osquery.ServerTimeout(time.Duration(*flTimeout)*time.Second),
	)
	if err != nil {
		log.Fatalf("creating extension: %s\n", err)
	}
	defer server.Shutdown(context.TODO())

	// create a table
	columns := []table.ColumnDefinition{table.TextColumn("issue")}
	table := table.NewPlugin("issue_5326", columns, func(_ context.Context, _ table.QueryContext) ([]map[string]string, error) {
		return []map[string]string{map[string]string{"issue": "5326"}}, nil
	})

	logger := logger.NewPlugin("dev_logger", func(_ context.Context, logType logger.LogType, logText string) error {
		var out bytes.Buffer
		json.Indent(&out, []byte(logText), "", "  ")
		out.WriteString("\n")
		_, err := out.WriteTo(os.Stdout)
		return err
	})
	server.RegisterPlugin(table, logger)

	log.Fatal(server.Run())
}
