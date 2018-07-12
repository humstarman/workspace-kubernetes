TARGET_HOST=192.168.100.167
GROUP=hosts
TMP=tmp

build:
	@./scripts/mk-ansible-hosts.sh -i ${TARGET_HOST} -g ${TMP} -o

run:
	@ansible ${TMP} -m script -a "./scripts/mk-scripts.sh -g ${GROUP}"
	@./scripts/rm-ansible-group.sh -g ${TMP}

clean:
	@./scripts/mk-ansible-hosts.sh -i ${TARGET_HOST} -g ${TMP} -o
	@ansible ${TMP} -m script -a "./scripts/rm-scripts.sh"
	@./scripts/rm-ansible-group.sh -g ${TMP}

local_clean:
	@./scripts/rm-scripts.sh

oldtest:
	@./scripts/mk-scripts.sh -g all
	@cat /etc/crontab
	@ls -al /usr/local/bin
old2test:
	@echo ${RAND}
	@echo ${THIS_IP}

test:
	@./scripts/mk-ansible-hosts.sh -i ${TARGET_HOST} -g ${TMP} -o
	@ansible ${TMP} -m shell -a "cat /etc/crontab"
	@ansible ${TMP} -m shell -a "ls /usr/local/bin"
	@./scripts/rm-ansible-group.sh -g ${TMP}

all: build run
