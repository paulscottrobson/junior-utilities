@echo off
REM Reprogram flash sectors based on a CSV file

python %FOENIXMGR%\FoenixMgr\fnxmgr.py --flash-bulk %1
