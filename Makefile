##
## This section has common project settings you may need to change.
##

ifeq ($(OS),Windows_NT)
   FLEX_SDK=c:/FlexSDK
   ANDROID_SDK=c:/android-sdk
else
   FLEX_SDK=~/ApacheFlex
   ANDROID_SDK=~/android-sdks
endif

APP=ld28

APP_XML=$(APP).xml

#Part of the line below is commented out because I don't have those files
SOURCES=src/Startup.hx src/Root.hx #src/TitleMenu.hx src/Credits.hx src/Battle.hx src/Instructions.hx

##
## It's less common that you would need to change anything after this line.
##

SIGN_CERT=sign.pfx

SIGN_PWD=abc123

SWF_VERSION=11.8

ADL=$(FLEX_SDK)/bin/adl

ADT=$(FLEX_SDK)/bin/adt

AMXMLC=$(FLEX_SDK)/bin/amxmlc

##
## Build rules
##

all: $(APP).swf $(APP)Web.swf

apk: $(APP).apk

clean:
	rm -rf $(APP).swf $(APP).apk

test: $(APP).swf
	$(ADL) -profile tv -screensize 1920x1080:1920x1080 $(APP_XML)

testHi: $(APP).swf
	$(ADL) -profile tv -screensize 1920x1080:1920x1080 $(APP_XML)

sign.pfx:
	$(ADT) -certificate -validityPeriod 25 -cn SelfSigned 1024-RSA $(SIGN_CERT) $(SIGN_PWD)

install: $(APP).apk
	$(ADT) -installApp -platform android -platformsdk $(ANDROID_SDK) -package $(APP).apk

$(APP)Web.swf: $(SOURCES)
	haxe \
	-cp src \
	-cp vendor \
	-swf-version $(SWF_VERSION) \
	-swf-header 1920:1080:60:ffffff \
	-main Startup \
	-swf $(APP)Web.swf \
	-swf-lib vendor/gamepadWeb.swc \
	-swf-lib vendor/starling.swc --macro "patchTypes('vendor/starling.patch')"

$(APP).swf: $(SOURCES)
	haxe \
	-cp src \
	-cp vendor \
	-swf-version $(SWF_VERSION) \
	-swf-header 1920:1080:60:ffffff \
	-main Startup \
	-lib air3 \
	-swf $(APP).swf \
	-swf-lib vendor/starling.swc --macro "patchTypes('vendor/starling.patch')"

$(APP).apk: $(APP).swf sign.pfx
	$(ADT) -package -target apk-captive-runtime -storetype pkcs12 -keystore $(SIGN_CERT) $(APP).apk $(APP_XML) $(APP).swf assets game_icon.png




