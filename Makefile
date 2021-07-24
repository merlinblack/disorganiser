# Nigels wizzzy "simple" makefile
# ###################################################################
#
ifeq ($(shell uname -s),Darwin)
	LUA=lua5.3
else
	ifeq ($(shell arch), armv7l)
		LUA=lua5.3
	else
		LUA=lua
	endif
endif
CXX = g++
SDL_LIBS = -lSDL2 -lSDL2_image -lSDL2_ttf
CXXFLAGS += -std=c++17 -g
CXXFLAGS += $(shell pkg-config --cflags $(LUA))
LDFLAGS  += $(shell pkg-config   --libs $(LUA)) $(SDL_LIBS)
EXECUTABLE := hub_commander
INSTALLABLE_SCRIPTS := 
SOURCES := main.cpp application.cpp sdl.cpp texture.cpp font.cpp timer.cpp
OBJDIR := obj
DEPDIR := deps
INSTALLDIR := $(HOME)/oyunum
VPATH := src

# ###################################################################

.SILENT: $(DEPS) $(DEPDIR) $(OBJDIR) clean

OBJECTS=$(addprefix $(OBJDIR)/,$(SOURCES:.cpp=.o))
DEPS=$(addprefix $(DEPDIR)/,$(SOURCES:.cpp=.d))

.PHONY: all
all:	$(OBJDIR) $(SOURCES) $(DEPS) gitversioning.h $(EXECUTABLE)

.PHONY: install
install:
	mkdir -p $(INSTALLDIR)
	cp $(EXECUTABLE) $(INSTALLABLE_SCRIPTS) $(INSTALLDIR)

$(EXECUTABLE):	$(OBJECTS)
	$(CXX) $(LDFLAGS) $(OBJECTS) $(LIBS) -o $@

# Squeeky
# ########
.PHONY: clean
clean:
	echo 'Cleaning'
	rm -f $(OBJECTS) $(EXECUTABLE) gitversioning.h
	rm -rf $(DEPDIR)
	rm -rf $(OBJDIR)

# Object files
# #############
#
$(OBJDIR)/%.o: %.cpp | $(OBJDIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(OBJDIR):
	mkdir -p $(OBJDIR)

# Dependency files
# #################
#
# Make sure gitversioning.h is made before trying to make
# any dependency file

$(DEPDIR)/%.d: %.cpp gitversioning.h | $(DEPDIR)
	@echo "Caching dependency info for: $<"
	@$(CC) $(CXXFLAGS) -MF"$@" -MG -MP -MM -MT"$(OBJDIR)/$(notdir $(<:.cpp=.o)) $@" "$<"

$(DEPDIR):
	mkdir -p $(DEPDIR)

ifeq (0,$(words $(findstring clean, $(MAKECMDGOALS))))
	# Don't make these, only to clean them out again.
-include $(DEPS)
endif

# gitversioning.h is remade when either git tags or heads change.
gitversioning.h: .git/refs/tags .git/refs/heads .git/HEAD
	@./gitversioning.sh
