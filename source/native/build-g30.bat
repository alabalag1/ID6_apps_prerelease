@echo off
call C:\QNX650\qnx650-env.bat >nul 2>&1
cd /d %~dp0
if not exist out mkdir out
set C=qcc -V4.4.2,gcc_ntoarmv7le -Wc,-std=c99 -Wall -Wextra -Werror
set X=qcc -V4.4.2,gcc_ntoarmv7le_gpp -lang-c++ -Wc,-std=gnu++98 -Wall -Wextra -Werror
set FW=frameworks\libAppFramework.A.so frameworks\libCoreFramework.A.so
%C% -DPERF_LAB -Isrc -O2 -fPIC -c src/gauge_core.c -o out/core.o || goto fail
%X% -DPERF_LAB -Isrc -Isdk -O2 -fno-strict-aliasing -fno-exceptions -fPIC -shared src/plugin.cpp out/core.o %FW% -lm -lsocket -Wl,--allow-shlib-undefined -Wl,-soname,libBoostDeck.so -o out/libBoostDeck.so || goto fail
%C% -DNATIVE_FAST -DPERF_LAB -Isrc -O2 src/collector.c out/core.o -lm -lsocket -o out/boostdeck-collector-qnx || goto fail
%X% -DPERF_LAB -Isrc -Isdk -O2 -fno-exceptions -fPIC -shared -DNATIVE_SHIFT_SMOOTH src/shift_deck.cpp out/core.o %FW% -lm -lsocket -Wl,--allow-shlib-undefined -Wl,-soname,libShiftDeck.so -o out/libShiftDeck.so || goto fail
%C% -DNATIVE_FAST -Isrc -O2 -DSHIFT_DECK_ONLY src/collector.c out/core.o -lm -lsocket -o out/shift-deck-qnx || goto fail
%X% -DPERF_LAB -Isrc -Isdk -O2 -fno-strict-aliasing -fno-exceptions -fPIC -shared src/engine_codes.cpp out/core.o %FW% -lm -lsocket -Wl,--allow-shlib-undefined -Wl,-soname,libEngineCodes.so -o out/libEngineCodes.so || goto fail
%C% -Isrc -O2 -DENGINE_CODES_ONLY src/collector.c out/core.o -lm -lsocket -o out/engine-codes-qnx || goto fail
%C% -Isrc -O2 -DBM3_ONLY src/collector.c out/core.o -lm -lsocket -o out/bootmod3-qnx || goto fail
%X% -Isrc -Isdk -O2 -DBM3_ONLY -fno-exceptions -fPIC -shared src/mhd_maps.cpp %FW% -lsocket -Wl,--allow-shlib-undefined -Wl,-soname,libBootmod3Suite.so -o out/libBootmod3Suite.so || goto fail
%C% -Isrc -O2 -DXDRIVE_ONLY src/collector.c out/core.o -lm -lsocket -o out/xdrive-control-qnx || goto fail
%X% -Isrc -Isdk -O2 -DXDRIVE_ONLY -fno-exceptions -fPIC -shared src/mhd_maps.cpp %FW% -lsocket -Wl,--allow-shlib-undefined -Wl,-soname,libXDriveControl.so -o out/libXDriveControl.so || goto fail
echo BUILD-OK
goto :eof
:fail
echo BUILD-FAILED
