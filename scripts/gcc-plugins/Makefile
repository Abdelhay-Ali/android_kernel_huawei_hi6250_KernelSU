randomize_layout.so: randomize_layout_plugin.c
	g++ -Wall -g -Iaarch64-linux-android-4.9/lib/gcc/aarch64-linux-android/4.9.x/plugin/include -fpic -shared -fno-rtti -o $@ randomize_layout_plugin.c

ifeq ($(PLUGINCC),$(HOSTCC))
  HOSTLIBS := hostlibs
  HOST_EXTRACFLAGS += -I$(GCC_PLUGINS_DIR)/include -I$(src) -std=gnu99 -ggdb
  export HOST_EXTRACFLAGS
else
  HOSTLIBS := hostcxxlibs
  HOST_EXTRACXXFLAGS += -I$(GCC_PLUGINS_DIR)/include -I$(src) -std=gnu++98 -fno-rtti
  HOST_EXTRACXXFLAGS += -fno-exceptions -fasynchronous-unwind-tables -ggdb
  HOST_EXTRACXXFLAGS += -Wno-narrowing -Wno-unused-variable
  HOST_EXTRACXXFLAGS += -Wno-format-diag
  export HOST_EXTRACXXFLAGS
endif


structleak.so: structleak_plugin.c
	g++ -Wall -g -Iaarch64-linux-android-4.9/lib/gcc/aarch64-linux-android/4.9.x/plugin/include -fpic -shared -fno-rtti -o $@ structleak_plugin.c
