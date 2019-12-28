OUTDIR:=out
CMDDIR:=cmd
CMDS:=$(wildcard $(CMDDIR)/*)
VERSION=$(shell git describe --tags --always --dirty)

.PHONY: all $(CMDS)

all: $(CMDS)

clean:
	rm -rf out

$(CMDS):
	mkdir -p $(OUTDIR)
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags '-s -w' -o $(patsubst $(CMDDIR)/%,$(OUTDIR)/%,$@) ./$@

release: $(CMDS)
	echo "$(patsubst $(CMDDIR)/%,$(OUTDIR)/%,$<)" | scripts/release.sh sig $(VERSION)
