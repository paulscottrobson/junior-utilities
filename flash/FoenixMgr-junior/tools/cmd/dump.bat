@echo off
REM Print the contents of memory
REM usage: dump {start address} [{byte count}]

if [%2%]==[] (
    python %FOENIXMGR%\FoenixMgr\fnxmgr.py --dump %1
) ELSE (
    python %FOENIXMGR%\FoenixMgr\fnxmgr.py --dump %1 --count %2
)
