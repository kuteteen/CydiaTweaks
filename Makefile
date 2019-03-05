TWEAKS = autovpn/tweak ccvpn homegesture nosimalert
TWEAKS_NOFINAL = forcechinese unforcechinese
TARGET = $(TWEAKS:=.t) $(TWEAKS_NOFINAL:=.tn)

all: $(TARGET)
	@echo "All done!"

%.t:
	$(eval DIR:=$(patsubst %.t,%,$@))
	make -C $(DIR) package FINALPACKAGE=1
	mv $(DIR)/packages/*.deb . 

%.tn:
	$(eval DIR:=$(patsubst %.tn,%,$@))
	make -C $(DIR) package DEBUG=0 VERSION.INC_BUILD_NUMBER=1
	mv $(DIR)/packages/*.deb .

clean:
	find . -name .theos -type d -exec rm -rf {} +
	find . -name packages -type d -exec rm -rf {} +

.PHONY: all clean
