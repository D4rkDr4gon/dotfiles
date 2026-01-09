#!/bin/bash

kitty bash -c '
ollama serve > /dev/null 2>&1 &
sleep 2
ollama run gemma3:270m
'
