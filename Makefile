GOFLAGS?=
export GOOS?=linux
CGO_ENABLED?=0
export GO111MODULE?=on
export GOPRIVATE?=github.com/DataDog*
TARGET=kube-sync
PACKAGE=github.com/DataDog/kube-sync

.PHONY: all
all: $(TARGET) $(TARGET).sha256sum

$(TARGET):
	CGO_ENABLED=$(CGO_ENABLED) go build $(GOFLAGS) $(LDFLAGS) -o $(TARGET) ./cmd/$(TARGET)

$(TARGET).sha256sum: $(TARGET)
	sha256sum $(TARGET) > $(TARGET).sha256sum

.PHONY: $(TARGET)-docker
$(TARGET)-docker: $(TARGET)
	docker build -t $(TARGET):local .

.PHONY: clean
clean:
	$(RM) $(TARGET) $(TARGET).sha256sum

.PHONY: clean-docker
clean-docker:
	docker rmi $(TARGET)

.PHONY: clean-all
clean-all: clean clean-docker

re: clean $(NAME)

docs:
	go run ./scripts/update/docs.go

license:
	./scripts/update/license.sh

check:
	go test -v ./pkg/...

fmt: ; go fmt ./...
.PHONY: fmt

pristine:
	git ls-files --exclude-standard --modified --deleted --others | diff /dev/null -
.PHONY: pristine

verify-fmt: fmt pristine
.PHONY: verify-fmt

verify-docs:
	./scripts/verify/docs.sh

verify-license:
	./scripts/verify/license.sh
