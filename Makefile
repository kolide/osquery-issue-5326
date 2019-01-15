run: TMPDIR := $(shell mktemp -d)
run: OSQUERYD = /Users/victor/code/osquery/buck-out/release/gen/osquery/osqueryd
run:
	echo "$(shell pwd)/bin/issue_5326.ext" > "$(TMPDIR)/extensions.load"
	go build -o bin/issue_5326.ext ./cmd/issue_5326_extension
	$(OSQUERYD) \
		--extensions_autoload=$(TMPDIR)/extensions.load \
		--logger_plugin=dev_logger \
		--config_path=./example_osquery_conf.json \
		--pidfile=$(TMPDIR)/osquery.pid \
		--database_path=$(TMPDIR)/osquery.db \
		--extensions_socket=$(TMPDIR)/osquery.sock

container:
	docker build -t osq5326 .

run-container: TDIR := $(shell uuidgen)
run-container:
	mkdir -p /tmp/${TDIR}
	echo "/osq-bin/bin/issue_5326.ext" > "/tmp/$(TDIR)/extensions.load"
	GO111MODULE=on GOOS=linux go build -o bin/issue_5326.ext ./cmd/issue_5326_extension
	docker run -it --rm -v /tmp/$(TDIR):/osq -v $(PWD):/osq-bin --entrypoint osqueryd osq5326  \
		--extensions_autoload=/osq/extensions.load \
		--logger_plugin=dev_logger \
		--config_path=/osq-bin/example_osquery_conf.json \
		--pidfile=/osq/osquery.pid \
		--database_path=/osq/osquery.db \
		--extensions_socket=/osq/osquery.sock
