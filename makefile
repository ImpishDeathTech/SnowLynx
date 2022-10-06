
NAME   = snowlynx
SHARE  = /usr/share/$(NAME)
LIB    = /usr/lib/lua/5.4/$(NAME)
OBJ    = snow
BIN    = /usr/bin/snow

install:
	@echo Installing $(NAME) '>,..,>'
	@sudo mkdir $(SHARE)
	@sudo cp -r ./* $(SHARE)/

	@chmod +x snow
	@./snow install

remove:
	@echo Removing $(NAME) build system '>,..,>'
	@sudo rm -r $(SHARE)
	@sudo rm -r $(LIB)
	@sudo rm $(BIN)
	@echo Done '^,..,^'